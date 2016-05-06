public with sharing class CreateDocumentSubscription {
	public static void createSubscription(List<ContentDocument> documents){
		Set<Id> contentVersionIds = new Set<Id>();
		Map<Id, ContentVersion> contentMap = new Map<Id, ContentVersion>();
		for(ContentDocument cd : documents){
			contentVersionIds.add(cd.LatestPublishedVersionId);
		}

		for(List<ContentVersion> versions : [SELECT Id, ContentDocumentId, TagCsv FROM ContentVersion WHERE Id IN :contentVersionIds]){
			for(ContentVersion version : versions){
				contentMap.put(version.ContentDocumentId, version);
			}
		}
		
		List<EntitySubscription> entitySubscriptions = new List<EntitySubscription>();
		
		for(Id documentId : contentMap.keySet()){
			List<String> tags = contentMap.get(documentId).TagCsv.split(',');
			for(String tag : tags){
				if(tag.equals('xml')){
					//EntitySubscription es = new EntitySubscription(ParentId = contentMap.get(documentId).ContentDocumentId, SubscriberId=Userinfo.getUserId());#
					EntitySubscription es = new EntitySubscription(ParentId = contentMap.get(documentId).ContentDocumentId, SubscriberId='005i0000003XuJU');
					entitySubscriptions.add(es);
				}
			}
		}

		try {
			insert entitySubscriptions;
		} catch(Exception e){
			system.debug('@@@@ calling createSubscription - the following error occured when creating a subscription: ' + e);
		}
	}
}