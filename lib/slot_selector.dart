import 'package:dart_date/dart_date.dart';
import 'package:flutter/foundation.dart';
import 'package:scheduler/date_range.dart';
import 'package:scheduler/services/scheduler_service.dart';
import 'package:scheduler/time_slot.dart';

class SlotSelector extends ChangeNotifier {
   DateRange selectedSlotDates = DateRange();
   TimeSlot? _selectionStartSlot;
   TimeSlot? _selectionEndSlot;
   bool isSelecting = false;

   get durationOfSlots => Duration(minutes: _selectionEndSlot!.endDate.differenceInMinutes(_selectionStartSlot!.startDate));

   startSelection(TimeSlot slot) {
     if (isSelecting){
       return;
     }
     _selectionStartSlot = slot;
     isSelecting = true;
     selectRange(slot, slot);
   }
   endSelection() {
     isSelecting = false;
     SchedulerService().scheduler.dataSource!.addAppointment(selectedSlotDates.dates.first, durationOfSlots, "New");
   }

   selectRange(TimeSlot startSlot, TimeSlot endSlot) {
     _selectionStartSlot = startSlot;
     _selectionEndSlot = endSlot;
     selectedSlotDates.setRange(startSlot.startDate, endSlot.startDate);
     notifyListeners();
   }
   select(TimeSlot slot){
     selectRange(_selectionStartSlot!, slot);
   }
   clearSelection() {
     selectedSlotDates.clearRange();
     notifyListeners();
   }
   @override
   void addListener(VoidCallback listener) {
      super.addListener(listener);
      listener();
   }
}