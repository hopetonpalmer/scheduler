import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LongPressDraggableEx<T extends Object> extends LongPressDraggable<T> {
  final bool Function()? allowDragGesture;
  const LongPressDraggableEx({
    super.key,
    required super.child,
    required super.feedback,
    super.data,
    super.axis,
    super.childWhenDragging,
    super.feedbackOffset,
    super.dragAnchorStrategy,
    super.maxSimultaneousDrags,
    super.onDragStarted,
    super.onDragUpdate,
    super.onDraggableCanceled,
    super.onDragEnd,
    super.onDragCompleted,
    super.hapticFeedbackOnStart = true,
    super.ignoringFeedbackSemantics,
    super.ignoringFeedbackPointer,
    super.delay = kLongPressTimeout,
    this.allowDragGesture,
  });

  @override
  DelayedMultiDragGestureRecognizerEx createRecognizer(GestureMultiDragStartCallback onStart) {
    return DelayedMultiDragGestureRecognizerEx(delay: delay, allowDragGesture: allowDragGesture)
      ..onStart = (Offset position) {
      final Drag? result = onStart(position);
        if (result != null && hapticFeedbackOnStart) {
          HapticFeedback.selectionClick();
        }

        return result;
      };
  }

}

class DelayedMultiDragGestureRecognizerEx extends DelayedMultiDragGestureRecognizer{
   final bool Function()? allowDragGesture;
   DelayedMultiDragGestureRecognizerEx({super.delay, this.allowDragGesture});

   @override
   MultiDragPointerState createNewPointerState(PointerDownEvent event) {
     return DelayedPointerState(event.position, delay, true, event.kind, gestureSettings);
   }
}

class DelayedPointerState extends MultiDragPointerState {
  final bool ignoreDelayOnMove;
  DelayedPointerState(super.initialPosition, Duration delay, this.ignoreDelayOnMove,  super.kind, super.deviceGestureSettings) {
    _timer = Timer(delay, _delayPassed);
  }

  Timer? _timer;
  GestureMultiDragStartCallback? _starter;

  void _delayPassed() {
    assert(_timer != null);
    assert(pendingDelta != null);
    assert(pendingDelta!.distance <= computeHitSlop(kind, gestureSettings));
    _timer = null;
    if (_starter != null) {
      _starter!(initialPosition);
      _starter = null;
    } else {
      resolve(GestureDisposition.accepted);
    }
    assert(_starter == null);
  }

  void _ensureTimerStopped() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void accepted(GestureMultiDragStartCallback starter) {
    assert(_starter == null);
    if (_timer == null) {
      starter(initialPosition);
    } else {
      _starter = starter;
    }
  }

  @override
  void checkForResolutionAfterMove() {
    if (_timer == null) {
      assert(_starter != null);

      return;
    }
    assert(pendingDelta != null);

    if (ignoreDelayOnMove && _timer != null) {
      cancelTimeAndStartDrag();

      return;
    }

    if (pendingDelta!.distance > computeHitSlop(kind, gestureSettings)) {
      resolve(GestureDisposition.rejected);
      _ensureTimerStopped();
    }
  }

  cancelTimeAndStartDrag() {
    _ensureTimerStopped();
    if (_starter != null) {
      _starter!(initialPosition);
      _starter = null;
    }
  }

  @override
  void dispose() {
    _ensureTimerStopped();
    super.dispose();
  }
}