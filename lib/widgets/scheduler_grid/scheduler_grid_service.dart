import 'dart:ui';




class TimeSlotGridService {
    static Offset cellOffsetOfPos(Offset position, Size slotSize, Offset offset) {
        position = Offset(position.dx-offset.dx, position.dy - offset.dy);
        int colsOfPos = (position.dx / slotSize.width).floor();
        int rowsOfPos = (position.dy / slotSize.height).floor();
        Offset result = Offset(colsOfPos * slotSize.width + offset.dx, rowsOfPos * slotSize.height + offset.dy);
        return result;
    }


}