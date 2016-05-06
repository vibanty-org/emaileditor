public with sharing class CtrRecordLookUp {
	public String typ { get; set; }
	public String searchString { get; set; }
	public String searchFields { get; set; }
	public List<String> selectedFields {get; set;}
	public String objName { get; set; }
	public String parentId { get; set; }
	public String folderId { get; set; }
	public String selectedFiles { get; set; }
	public Map<Id, String> selectedFilesMap { get; set; }
	public String recordName { get; set; }
	public String recordId { get; set; }
	public List<SObject> records { get; set; }
	public List<FieldList> objectFields { get; set; }
	public List<DocumentList> documentList { get; set; }
	public List<AttachmentList> attachmentList { get; set; }
	public List<SelectOption> folders { get; set; }
	public String recipientType { get; set; }
	public List<SObject> recipients { get; set; }
	
	public CtrRecordLookUp() {
		this.typ = ApexPages.currentPage().getParameters().get('typ');
		this.selectedFilesMap = new Map<Id, String>();
		if(typ.equals('search')){
			this.objName = Apexpages.currentPage().getParameters().get('objName');
			this.searchString = Apexpages.currentPage().getParameters().get('searchString');
			this.searchFields = Apexpages.currentPage().getParameters().get('searchFields');
			this.performSearch();
		} else if(typ.equals('fields')){
			this.objName = Apexpages.currentPage().getParameters().get('objName');
			this.buildFieldList();
		} else if(typ.equals('document')) {
			this.folderId = Apexpages.currentPage().getParameters().get('folderId');
			this.selectedFiles = Apexpages.currentPage().getParameters().get('selectedFiles');
			this.buildSelectedFiles();
			this.buildDocumentList();
		} else if(typ.equals('attachment')) {
			this.parentId = Apexpages.currentPage().getParameters().get('parentId');
			this.selectedFiles = Apexpages.currentPage().getParameters().get('selectedFiles');
			this.buildSelectedFiles();
			this.buildAttachmentList();
		} else if(typ.equals('recipientType')){
			system.debug('@@@@ constructor - recipientType : ' + typ);
			this.recipientType = Apexpages.currentPage().getParameters().get('recipientType');
			system.debug('@@@@ constructor - recipientType : ' + this.recipientType);
			this.recipients = new List<SObject>();
			this.buildRecipient();
		}
	}
	
	public void buildSelectedFiles(){
		system.debug('@@@@ buildSelectedFiles - this.selectedFiles : ' + this.selectedFiles);
		if(String.isNotBlank(this.selectedFiles)){
			List<String> strParts = this.selectedFiles.split(',');
			for(String str : strParts){
				selectedFilesMap.put(Id.valueOf(str), str);
			}
		}
	}
	
	public void performSearch(){
		this.records = new List<SObject>();
		String query = 'SELECT ';
		String fieldsToSelect = 'Id';
		String whereClaus = '';
		this.selectedFields = this.searchFields.split(',');
		system.debug('@@@@ calling performSearch : ' + selectedFields);
		system.debug('@@@@ calling performSearch.size() : ' + selectedFields.size());
		//if(String.isNotBlank(this.searchString) && !selectedFields.isEmpty()){
		if(String.isNotBlank(this.searchFields) && String.isNotBlank(this.searchString)){
		 	//query += ' WHERE (Name LIKE \'%' + String.escapeSingleQuotes(this.searchString) + '%\' OR Business_Unit__c LIKE \'%' + String.escapeSingleQuotes(this.searchString) + '%\' OR Phone LIKE \'%' + String.escapeSingleQuotes(this.searchString) + '%\' OR Email LIKE \'%' + String.escapeSingleQuotes(this.searchString) + '%\')';
			//query += ' WHERE (Name LIKE \'%' + String.escapeSingleQuotes(this.searchString) + '%\')';
			//query += ' WHERE ';
			whereClaus += ' WHERE ';
			//for(String str : parts){

			for(Integer i = 0; i <  selectedFields.size(); i++){
				//fieldsToSelect += selectedFields[i] + ' ,';
				fieldsToSelect += ', ' + selectedFields[i];
				if(i == 0){
					whereClaus += '( ' + selectedFields[i] + ' LIKE \'%' + String.escapeSingleQuotes(this.searchString) + '%\')';
				} else {
					whereClaus += ' OR ( ' + selectedFields[i] + ' LIKE \'%' + String.escapeSingleQuotes(this.searchString) + '%\')';
				}
				
			}
		 
			system.debug('@@@@ calling performSearch - fieldsToSelect: ' + fieldsToSelect);
			system.debug('@@@@ calling performSearch - whereClaus: ' + whereClaus);
			//fieldsToSelect = fieldsToSelect.substring(0, fieldsToSelect.length() - 1);
			//query += ' ORDER BY Name';
			query += fieldsToSelect  + ' FROM ' + this.objName + whereClaus;

			system.debug('@@@@ performSearch - query : ' +  query);

			this.records = database.query(query);
			system.debug('@@@@ performSearch : ' +  records);

			/*this.recordId = records[0].Id;
			this.recordName = (String)records[0].get('Name');*/
		}
	}

	public void buildFieldList(){
		system.debug('@@@@ calling buildFieldList - objName : ' + this.objName);
		system.debug('@@@@ calling buildFieldList - objectFields before : ' + this.objectFields);
		if(this.objName != null){
			//this.objectFields = new List<SelectOption>();
			this.objectFields = new List<FieldList>();
			SObjectType sType = Schema.getGlobalDescribe().get(this.objName);
			system.debug('@@@@ calling buildFieldList - objectFields sType : ' + sType);
			Map<String,Schema.SObjectField> mfields = sType.getDescribe().fields.getMap();
			system.debug('@@@@ calling buildFieldList - objectFields mfields : ' + mfields);
			system.debug('@@@@ mfields : ' + mfields);
			for(Schema.SObjectField field : mfields.Values()){
			    system.debug('NName : ' + field.getDescribe().getName() + 'TType : ' + field.getDescribe().getType() + 'TType Name : ' + field.getDescribe().getType().name());
			    //if(field.getDescribe().getType().name().equals('PICKLIST') || field.getDescribe().getType().name().equals('STRING') || field.getDescribe().getType().name().equals('TEXTAREA') || field.getDescribe().getType().name().equals('EMAIL')){
			    if(field.getDescribe().getType().name().equals('PICKLIST') || field.getDescribe().getType().name().equals('STRING') || field.getDescribe().getType().name().equals('EMAIL')){
			    	//this.objectFields.add(new SelectOption(field.getDescribe().getName(), field.getDescribe().getName()));
			    	objectFields.add(new FieldList(field.getDescribe().getName(), this.objectFields.size()));
			    }
			}
		}
		system.debug('@@@@ calling buildFieldList - objectFields after : ' + this.objectFields);
	}

	public void buildDocumentList(){
		system.debug('@@@@ calling buildDocumentList - folderId : ' + folderId);
		if(this.folders == null){
			ClsEmailEditorHelper helper = new ClsEmailEditorHelper();
			this.folders = new List<SelectOption>();
			this.folders = helper.getFolderListOptions();
			system.debug('@@@@ calling buildDocumentList - folders : ' + this.folders);
		}
		if(this.folderId != null){
			this.documentList = new List<DocumentList>();
			List<Document> docs = [SELECT Id, Name, BodyLength, ContentType, Url FROM Document WHERE FolderId =: folderId];
			for(Document doc : docs){
				this.documentList.add(new DocumentList(doc, this.documentList.size(), this.selectedFilesMap));
			}
		}
	}

	public void buildRecipient(){
		String query = 'SELECT Id, Name, Email FROM ' + this.recipientType;
		system.debug('@@@@ buildRecipient - query : ' + query);
		this.recipients = Database.query(query);
		system.debug('@@@@ buildRecipient - this.recipients : ' + this.recipients);
	}

	public void buildAttachmentList(){
		if(this.parentId != null){
			this.attachmentList = new List<AttachmentList>();
			List<Attachment> atts = [SELECT Id, Name, BodyLength, ContentType FROM Attachment WHERE ParentId =: this.parentId];
			for(Attachment att : atts){
				this.attachmentList.add(new AttachmentList(att, this.attachmentList.size(), this.selectedFilesMap));
			}
		}
	}

	public class FieldList{
		public Boolean selected { get; set; }
		public String fieldName { get; set; }
		public Integer position { get; set; }
		public FieldList(String fieldName, Integer position){
			this.fieldName = fieldName;
			this.selected = false;
			this.position = position;
		}
	}

	public class DocumentList{
		public Boolean selected { get; set; }
		public String documentName { get; set; }
		public String documentId { get; set; }
		public Integer position { get; set; }
		public Integer docSize { get; set; }
		public DocumentList(Document doc, Integer position, Map<Id,String> selectedFilesMap){
			this.documentName = doc.Name;
			this.documentId = doc.Id;
			this.docSize = doc.BodyLength;
			this.position = position;
			if(selectedFilesMap.get(doc.Id) != null){
				this.selected = true;
			} else {
				this.selected = false;
			}
		}
	}

	public class AttachmentList{
		public Boolean selected { get; set; }
		public String attachmentName { get; set; }
		public String attachmentId { get; set; }
		public Integer position { get; set; }
		public Integer docSize { get; set; }
		public AttachmentList(Attachment att, Integer position, Map<Id,String> selectedFilesMap){
			this.attachmentName = att.Name;
			this.attachmentId = att.Id;
			this.docSize = att.BodyLength;
			this.position = position;
			if(selectedFilesMap.get(att.Id) != null){
				this.selected = true;
			} else {
				this.selected = false;
			}
		}
	}
	/*public class RecordList{
		public List<String> records { get; set; }
	}*/
}