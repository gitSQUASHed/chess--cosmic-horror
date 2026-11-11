"""Render a selected Blender model as an 8-direction pixel-art sprite sheet.

Paste this script into Blender's Text Editor, set the configuration values below,
select the model root (usually an Armature or an Empty), and press Run Script.

The output sheet is laid out as one row per animation frame and one column per
view direction.  A matching JSON file is written for importing it in Godot.
"""

import json
import math
import os
import shutil
import tempfile

import bpy
from mathutils import Vector


# ---------------------------------------------------------------------------
# User configuration
# ---------------------------------------------------------------------------

# Blender-relative paths begin with // and resolve beside the .blend file.
OUTPUT_PATH = "//exports/sprites/sprite_sheet.png"
METADATA_PATH = None  # None writes sprite_sheet.json beside OUTPUT_PATH.

# "ACTION_RANGE" renders every whole frame in the active action's range.
# "KEYFRAMES" renders only the frames that have a key in that action.
# "TIME_INTERVAL" renders a sample every SAMPLE_INTERVAL_SECONDS.
# "CURRENT_FRAME" renders one frame and is useful for testing the setup.
FRAME_MODE = "ACTION_RANGE"
SAMPLE_INTERVAL_SECONDS = 0.2  # Used only by TIME_INTERVAL.

PIXELS_PER_METER = 16
BLENDER_UNITS_PER_METER = 1.0
SUPERSAMPLE_FACTOR = 4
SPRITE_PADDING = 1

CAMERA_TILT_DEGREES = 30.0
CAMERA_DISTANCE = 6.5
CAMERA_HEIGHT_OFFSET = 0.0
DIRECTION_START_DEGREES = 0.0

# These labels are written into the metadata in left-to-right column order.
# Change the labels/order to match the forward direction of the source model.
DIRECTION_LABELS = (
    "front", "front_right", "right", "back_right",
    "back", "back_left", "left", "front_left",
)

TRANSPARENT_BACKGROUND = True
EEVEE_RENDER_SAMPLES = 64
RENDER_FILTER_SIZE = 0.5
EDGE_SHARPNESS = 0.0


# ---------------------------------------------------------------------------
# Scene/model helpers
# ---------------------------------------------------------------------------

def get_target():
    target = bpy.context.active_object
    if target is None:
        raise RuntimeError("Select a model root, Armature, or mesh before running this script.")
    return target


def get_model_objects(target):
    """Return the selected root and every descendant exactly once."""
    objects = []
    pending = [target]
    seen = set()
    while pending:
        obj = pending.pop()
        if obj is None or obj.name in seen:
            continue
        seen.add(obj.name)
        objects.append(obj)
        pending.extend(obj.children)
    return objects


def get_active_action(objects):
    """Find one active action, preferring the selected root's action."""
    for obj in objects:
        animation_data = obj.animation_data
        if animation_data and animation_data.action:
            return animation_data.action
    return None


def get_animation_frames(scene, objects, original_frame):
    if FRAME_MODE == "CURRENT_FRAME":
        return [original_frame]

    action = get_active_action(objects)
    if action is None:
        raise RuntimeError(
            "No active action was found below the selected object. "
            "Use FRAME_MODE = 'CURRENT_FRAME' for a still sprite."
        )

    if FRAME_MODE == "ACTION_RANGE":
        start, end = action.frame_range
        return list(range(math.floor(start), math.ceil(end) + 1))

    if FRAME_MODE == "KEYFRAMES":
        frames = set()
        for curve in action.fcurves:
            for point in curve.keyframe_points:
                frames.add(round(point.co.x))
        if not frames:
            raise RuntimeError("The active action has no keyframes.")
        return sorted(frames)

    if FRAME_MODE == "TIME_INTERVAL":
        if SAMPLE_INTERVAL_SECONDS <= 0:
            raise RuntimeError("SAMPLE_INTERVAL_SECONDS must be greater than zero.")
        start, end = action.frame_range
        frames_per_second = scene.render.fps / scene.render.fps_base
        sample_interval_frames = SAMPLE_INTERVAL_SECONDS * frames_per_second
        sample_count = math.floor((end - start) / sample_interval_frames + 1e-8)
        return [start + index * sample_interval_frames for index in range(sample_count + 1)]

    raise RuntimeError("FRAME_MODE must be ACTION_RANGE, KEYFRAMES, TIME_INTERVAL, or CURRENT_FRAME.")


def set_scene_time(scene, frame_value):
    """Set an integer frame and fractional subframe for exact time sampling."""
    whole_frame = math.floor(frame_value)
    scene.frame_set(whole_frame, subframe=frame_value - whole_frame)


def get_evaluated_bounds(objects):
    """Return world-space bounding-box corners for all visible render geometry."""
    depsgraph = bpy.context.evaluated_depsgraph_get()
    corners = []
    renderable_types = {"MESH", "CURVE", "SURFACE", "META", "FONT", "VOLUME", "POINTCLOUD"}
    for obj in objects:
        if obj.type not in renderable_types or obj.hide_render:
            continue
        evaluated = obj.evaluated_get(depsgraph)
        try:
            corners.extend(evaluated.matrix_world @ Vector(corner) for corner in evaluated.bound_box)
        except (AttributeError, TypeError, ValueError):
            continue
    if not corners:
        raise RuntimeError("Could not find renderable geometry below the selected object.")
    return corners


def calculate_animation_bounds(scene, objects, frames):
    """Use one union bound for every frame so the sprite never jumps or crops."""
    corners = []
    for frame in frames:
        set_scene_time(scene, frame)
        corners.extend(get_evaluated_bounds(objects))

    min_x = min(point.x for point in corners)
    max_x = max(point.x for point in corners)
    min_y = min(point.y for point in corners)
    max_y = max(point.y for point in corners)
    min_z = min(point.z for point in corners)
    max_z = max(point.z for point in corners)
    target_point = Vector(((min_x + max_x) * 0.5, (min_y + max_y) * 0.5,
                           (min_z + max_z) * 0.5 + CAMERA_HEIGHT_OFFSET))
    return corners, target_point


# ---------------------------------------------------------------------------
# Cameras and rendering
# ---------------------------------------------------------------------------

def point_at(obj, target):
    direction = Vector(target) - obj.location
    if direction.length == 0:
        raise RuntimeError("A generated camera overlaps its target point.")
    obj.rotation_euler = direction.to_track_quat("-Z", "Y").to_euler()


def create_cameras(target_point, bounds_corners):
    cameras = []
    radius = max((corner - target_point).length for corner in bounds_corners)
    distance = max(CAMERA_DISTANCE, radius * 2.0 + 1.0)
    tilt = math.radians(CAMERA_TILT_DEGREES)
    horizontal = distance * math.cos(tilt)
    vertical = distance * math.sin(tilt)

    try:
        for index, _label in enumerate(DIRECTION_LABELS):
            angle = math.radians(DIRECTION_START_DEGREES + index * 360.0 / len(DIRECTION_LABELS))
            data = bpy.data.cameras.new(f"SpriteCamera_{index:02d}_DATA")
            data.type = "ORTHO"
            data.sensor_fit = "HORIZONTAL"
            data.clip_start = 0.01
            data.clip_end = max(1000.0, distance + radius * 2.0)
            camera = bpy.data.objects.new(f"SpriteCamera_{index:02d}", data)
            camera.location = (
                target_point.x + math.cos(angle) * horizontal,
                target_point.y + math.sin(angle) * horizontal,
                target_point.z + vertical,
            )
            point_at(camera, target_point)
            bpy.context.collection.objects.link(camera)
            cameras.append(camera)
    except Exception:
        cleanup_cameras(cameras)
        raise
    return cameras


def get_frame_size(cameras, target_point, bounds_corners):
    pixels_per_unit = PIXELS_PER_METER / BLENDER_UNITS_PER_METER
    max_half_width = 0.0
    max_half_height = 0.0
    for camera in cameras:
        inverse_rotation = camera.rotation_euler.to_matrix().transposed()
        projected = [inverse_rotation @ (corner - target_point) for corner in bounds_corners]
        max_half_width = max(max_half_width, max(abs(point.x) for point in projected))
        max_half_height = max(max_half_height, max(abs(point.y) for point in projected))
    return (
        max(1, math.ceil(max_half_width * 2.0 * pixels_per_unit) + SPRITE_PADDING * 2),
        max(1, math.ceil(max_half_height * 2.0 * pixels_per_unit) + SPRITE_PADDING * 2),
    )


def configure_render(scene, frame_width, frame_height):
    engine_set = False
    for engine in ("BLENDER_EEVEE_NEXT", "BLENDER_EEVEE"):
        try:
            scene.render.engine = engine
            engine_set = scene.render.engine == engine
            if engine_set:
                break
        except (TypeError, ValueError):
            pass
    if not engine_set:
        raise RuntimeError("A supported EEVEE renderer is required.")

    scene.render.resolution_x = frame_width * SUPERSAMPLE_FACTOR
    scene.render.resolution_y = frame_height * SUPERSAMPLE_FACTOR
    scene.render.resolution_percentage = 100
    scene.render.film_transparent = TRANSPARENT_BACKGROUND
    scene.render.use_compositing = False
    scene.render.image_settings.file_format = "PNG"
    scene.render.image_settings.color_mode = "RGBA"
    scene.render.image_settings.compression = 6
    if hasattr(scene.render, "filter_size"):
        scene.render.filter_size = RENDER_FILTER_SIZE

    eevee = getattr(scene, "eevee", None)
    if eevee and hasattr(eevee, "taa_render_samples"):
        eevee.taa_render_samples = EEVEE_RENDER_SAMPLES


def set_camera_scale(cameras, frame_width):
    pixels_per_unit = PIXELS_PER_METER / BLENDER_UNITS_PER_METER
    for camera in cameras:
        camera.data.ortho_scale = frame_width / pixels_per_unit


def downsample_premultiplied(source, source_width, source_height, target_width, target_height):
    scale_x = source_width // target_width
    scale_y = source_height // target_height
    if scale_x != scale_y or source_width % target_width or source_height % target_height:
        raise ValueError("Supersampled render dimensions must be whole, equal multiples of the sprite size.")
    output = [0.0] * (target_width * target_height * 4)
    sample_count = scale_x * scale_y
    for y in range(target_height):
        for x in range(target_width):
            alpha_sum = red_sum = green_sum = blue_sum = 0.0
            for offset_y in range(scale_y):
                for offset_x in range(scale_x):
                    index = (((y * scale_y + offset_y) * source_width) + x * scale_x + offset_x) * 4
                    red, green, blue, alpha = source[index:index + 4]
                    alpha_sum += alpha
                    red_sum += red * alpha
                    green_sum += green * alpha
                    blue_sum += blue * alpha
            index = (y * target_width + x) * 4
            output[index + 3] = alpha_sum / sample_count
            if alpha_sum > 1e-8:
                output[index] = red_sum / alpha_sum
                output[index + 1] = green_sum / alpha_sum
                output[index + 2] = blue_sum / alpha_sum
    return output


def sharpen(pixels, width, height):
    if EDGE_SHARPNESS <= 0.0:
        return pixels
    source = pixels[:]
    result = pixels[:]
    for y in range(height):
        for x in range(width):
            center = (y * width + x) * 4
            if source[center + 3] <= 0.0:
                continue
            for channel in range(3):
                values = []
                for y_offset in (-1, 0, 1):
                    for x_offset in (-1, 0, 1):
                        if not x_offset and not y_offset:
                            continue
                        nx, ny = x + x_offset, y + y_offset
                        if 0 <= nx < width and 0 <= ny < height:
                            neighbour = (ny * width + nx) * 4
                            if source[neighbour + 3] > 0.0:
                                values.append(source[neighbour + channel])
                if values:
                    result[center + channel] = max(0.0, min(1.0, source[center + channel] +
                        EDGE_SHARPNESS * (source[center + channel] - sum(values) / len(values))))
    return result


def copy_frame(sheet, sheet_width, sprite, frame_width, frame_height, column, row):
    for y in range(frame_height):
        source_start = y * frame_width * 4
        target_start = ((row * frame_height + y) * sheet_width + column * frame_width) * 4
        sheet[target_start:target_start + frame_width * 4] = sprite[source_start:source_start + frame_width * 4]


# ---------------------------------------------------------------------------
# State preservation and output
# ---------------------------------------------------------------------------

def capture_render_state(scene):
    return {
        "engine": scene.render.engine,
        "resolution_x": scene.render.resolution_x,
        "resolution_y": scene.render.resolution_y,
        "resolution_percentage": scene.render.resolution_percentage,
        "filepath": scene.render.filepath,
        "film_transparent": scene.render.film_transparent,
        "use_compositing": scene.render.use_compositing,
        "filter_size": getattr(scene.render, "filter_size", None),
        "file_format": scene.render.image_settings.file_format,
        "color_mode": scene.render.image_settings.color_mode,
        "compression": scene.render.image_settings.compression,
    }


def restore_render_state(scene, state):
    for attr in ("resolution_x", "resolution_y", "resolution_percentage", "filepath",
                 "film_transparent", "use_compositing"):
        setattr(scene.render, attr, state[attr])
    if state["filter_size"] is not None and hasattr(scene.render, "filter_size"):
        scene.render.filter_size = state["filter_size"]
    scene.render.image_settings.file_format = state["file_format"]
    scene.render.image_settings.color_mode = state["color_mode"]
    scene.render.image_settings.compression = state["compression"]
    try:
        scene.render.engine = state["engine"]
    except (TypeError, ValueError):
        pass


def cleanup_cameras(cameras):
    for camera in cameras:
        data = camera.data
        bpy.data.objects.remove(camera, do_unlink=True)
        bpy.data.cameras.remove(data)


def save_metadata(path, output_path, frame_width, frame_height, frames):
    metadata = {
        "image": os.path.basename(output_path),
        "frame_width": frame_width,
        "frame_height": frame_height,
        "columns": len(DIRECTION_LABELS),
        "rows": len(frames),
        "directions": list(DIRECTION_LABELS),
        "source_frames": frames,
        "layout": "column = direction, row = animation frame",
    }
    with open(path, "w", encoding="utf-8") as metadata_file:
        json.dump(metadata, metadata_file, indent=2)


def render_sprite_sheet():
    scene = bpy.context.scene
    original_camera = scene.camera
    original_frame = scene.frame_current
    render_state = capture_render_state(scene)
    output_path = bpy.path.abspath(OUTPUT_PATH)
    metadata_path = bpy.path.abspath(METADATA_PATH) if METADATA_PATH else os.path.splitext(output_path)[0] + ".json"
    cameras, sheet_image, temp_directory = [], None, None

    try:
        target = get_target()
        objects = get_model_objects(target)
        frames = get_animation_frames(scene, objects, original_frame)
        bounds, target_point = calculate_animation_bounds(scene, objects, frames)
        cameras = create_cameras(target_point, bounds)
        frame_width, frame_height = get_frame_size(cameras, target_point, bounds)
        set_camera_scale(cameras, frame_width)
        configure_render(scene, frame_width, frame_height)

        sheet_width = frame_width * len(cameras)
        sheet_height = frame_height * len(frames)
        sheet_pixels = [0.0] * (sheet_width * sheet_height * 4)
        temp_directory = tempfile.mkdtemp(prefix="eight_direction_sprites_")

        for row, frame in enumerate(frames):
            set_scene_time(scene, frame)
            for column, camera in enumerate(cameras):
                render_path = os.path.join(temp_directory, f"sample_{row:04d}_direction_{column:02d}.png")
                scene.camera = camera
                scene.render.filepath = render_path
                bpy.ops.render.render(write_still=True)
                image = bpy.data.images.load(render_path, check_existing=False)
                try:
                    expected_width = frame_width * SUPERSAMPLE_FACTOR
                    expected_height = frame_height * SUPERSAMPLE_FACTOR
                    if tuple(image.size) != (expected_width, expected_height):
                        raise RuntimeError(f"Unexpected render size {tuple(image.size)} for {render_path}.")
                    pixels = downsample_premultiplied(list(image.pixels[:]), expected_width, expected_height,
                                                     frame_width, frame_height)
                    copy_frame(sheet_pixels, sheet_width, sharpen(pixels, frame_width, frame_height),
                               frame_width, frame_height, column, row)
                finally:
                    bpy.data.images.remove(image)
                    if os.path.exists(render_path):
                        os.remove(render_path)

        output_directory = os.path.dirname(output_path)
        metadata_directory = os.path.dirname(metadata_path)
        if output_directory:
            os.makedirs(output_directory, exist_ok=True)
        if metadata_directory:
            os.makedirs(metadata_directory, exist_ok=True)

        sheet_image = bpy.data.images.new("EightDirectionSpriteSheet", sheet_width, sheet_height, alpha=True)
        sheet_image.pixels[:] = sheet_pixels
        sheet_image.filepath_raw = output_path
        sheet_image.file_format = "PNG"
        sheet_image.save()
        save_metadata(metadata_path, output_path, frame_width, frame_height, frames)

        print(f"Saved sprite sheet: {output_path}")
        print(f"Saved metadata: {metadata_path}")
        print(f"Layout: {len(cameras)} directions x {len(frames)} frames; each frame is {frame_width}x{frame_height} px")
    finally:
        if sheet_image:
            bpy.data.images.remove(sheet_image)
        if cameras:
            cleanup_cameras(cameras)
        if temp_directory and os.path.isdir(temp_directory):
            shutil.rmtree(temp_directory, ignore_errors=True)
        scene.camera = original_camera
        scene.frame_set(original_frame)
        restore_render_state(scene, render_state)


if __name__ == "__main__":
    render_sprite_sheet()
