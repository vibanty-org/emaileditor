trigger CreateSubscriptionTrigger on ContentDocument (after insert, after update) {
	CreateDocumentSubscription.createSubscription(Trigger.new);
}