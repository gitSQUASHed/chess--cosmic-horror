# T-10 Capture sequence

## Scope
- When the king is caught, the capture ending plays as a physical sequence: the grabbing hand picks up the king, the camera moves in, and the pixel size animates, then the CAPTURED ending state starts.
- Uses the camera rig (T-03) animation API and the pixelation layer (T-04).
- Gameplay input and the hands stop during the sequence.

## Acceptance criteria
- Every capture type (sweep, grab, guiding hand) leads into the same sequence.
- The sequence cannot be interrupted or triggered twice.
