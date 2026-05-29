trigger ContactBenchTrigger on Contact (after update) {
    if (Trigger.isAfter && Trigger.isUpdate) {
        ContactBenchHandler.handleBenchConfirmation(Trigger.new, Trigger.oldMap);
    }
}