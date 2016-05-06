public with sharing class CtrEmailEditor extends ClsEmailEditorBase{

	public String sender { get; set; }
	public String fromBinding { get; set; }
	public List<SelectOption> senderDropdown { get; set; }
	public String to { get; set; }
	public String toBinding { get; set; }
	public String additionalTo { get; set; }
	public String cc { get; set; }
	public String bcc { get; set; }
	public String ccBinding { get; set; }
	public String bccBinding { get; set; }
	public String relatedTo { get; set; }
	public String subject { get; set; }
	public String content { get; set; }
	public String selectedEmailTemplateId { get; set; }
	public String htmlValueOfSelectedEmailtemplate { get; set; }
	public String defaultContentLabel { get; set; }
	public List<EmailEditorConfiguration__c> emailEditorConfig { get; set; }
	public ClsEmailEditorOptions editorOptions { get; set; }
	//public List<EmailRecipientWrapper> recipientList { get; set; }

	public Boolean saveAsActivity { get; set; }
	public Id whatId { get; set; }		   // Specificy if using template and targetObjectId
	public String searchString { get; set; }		   // Specificy if using template and targetObjectId
	public Id targetObjectId { get; set; } // Required if using a template
	//public Map<Id, OrgWideEmailAddress> OrgWideEmailAddressMap { get; set; } // The object's DisplayName field cannot be set if the setSenderDisplayName field is already set.
	//public List<OrgWideEmailAddress> orgWideEmailAddresses { get; set; }

	public List<SelectOption> emailTemplateSelectionList { get; set; }
	public Map<Id, EmailTemplate> emailTemplateMap { get; set; }
	public EmailTemplate selectedEmailTemplate { get; set; }

	public String selectedObject { get; set; }
	public List<SelectOption> objectNames { get; set; }
	public List<SelectOption> objectFields { get; set; }
	public String selectedFields { get; set; }

	public transient List<Attachment> attachmentsToUpload { get; set; }  
	public transient List<Messaging.Emailfileattachment> emailAttachmentsToSend { get; set; }  
	public List<String> attachmentNamesNew { get; set; }
	public List<String> attachmentNamesOld { get; set; }

	
	//public List<AdditionalAttachments> additionalAttachmentList { get; set; }
	 /*+ List of additionalAttachments */
    //public List<Attachment> additionalAttachments { get; set; }
    public List<AdditionalAttachments> additionalAttachments { get; set; }
	public String attachmentJsonString { get; set; }
	//public List<AttachmentList> attachmentList { get; set; }
	public Integer sizeOfDocuments { get; set; }
	public List<Document> documents { get; set; }

	public String selectedDocsBinding { get; set; }
	public String selectedAttsBinding { get; set; }

	public String emailAddressesFromLookUp { get; set; }
	public String searchOption { get; set; } // indicates the lookup whose data is to be processed e.g from, to, additionalTo etc
	public String recipientSearchOption { get; set; } // indicates whether the email addresses should be users, contacts or both.
	public Boolean useRunningUserEmail { get; set; } // Required in case org wide was choosen as default sender and no org wide email address exist

	public Boolean showSenderLookup { get; set; } // Show the lookup to select sender
	//public Boolean showOptionsOnPage { get; set; }
	//public Boolean showRecipientLookup { get; set; } // Show the lookup to select recipient
 
	// Additional Recipients
	//public Integer numberOfRecipientsToAdd { get; set; }
	//private static final Integer NUM_ADDITIONAL_RECIPIENTS_TO_ADD = 10;
	public Integer selectedNumberToAdd { get; set; }
	public Integer recipientToRemove { get; set; }
	public List<AdditionalRecipients> additionalRecipientsList { get; set; }

	public List<SelectOption> folders { get; set; }
	public String selectedFolder { get; set; }

	public String choosenTemplate { get; set; }

	public Boolean showEmailEditor { get; set; }

	public List<SelectOption> recipientTypes { get; set; }
	public String recipientType { get; set; }
	public Id selectedRecipientId { get; set; }

	public CtrEmailEditor() {
		this.whatId = ApexPages.currentPage().getParameters().get('recordId');
		this.emailEditorConfig = EmailEditorConfiguration__c.getall().values();
		this.showSenderLookup = false;
		this.determineSenderEmailAddresses();
		this.useRunningUserEmail = false;
		this.showEmailEditor = true;

		if(this.emailEditorConfig[0].Show_Options_On_Page__c){
			this.editorOptions = new ClsEmailEditorOptions();
			//this.editorOptions.determineOptions();
			this.editorOptions.determineOptionsForPage();
		}

		if(this.emailEditorConfig[0].Add_More_Recipents__c){
			this.additionalRecipientsList = new List<AdditionalRecipients>();
			this.selectedNumberToAdd = 1;
			this.manageRecipientList();
		}

		if(this.emailEditorConfig[0].Show_Folder_Selection__c){
			/*if(this.editorOptions == null){
				this.editorOptions = new ClsEmailEditorOptions();
				this.editorOptions.this.determineDefaultFolderOptions();
			}*/
			this.setSelectedFolder();
			this.buildTemplateDropdown();
		}
		
		if(this.emailEditorConfig[0].Allow_Related_To_Selection__c){
			this.buildObjectDropdown();
			this.buildRecipientTypeDropDown();
		}


		if((this.whatId == null ||  this.selectedEmailTemplateId == null) && this.emailEditorConfig[0].Use_Translatable_Default_Email_Content__c && String.isNotBlank(this.emailEditorConfig[0].Translatable_Default_Email_Content__c)){
			//this.defaultContentLabel = this.emailEditorConfig[0].Translatable_Default_Email_Content__c;
			//this.htmlValueOfSelectedEmailtemplate = this.emailEditorConfig[0].Translatable_Default_Email_Content__c;
			determineDefaultContent();
		}

		if(this.emailEditorConfig[0].Allow_Attachments__c && this.emailEditorConfig[0].Automatically_Attach_Documents__c){
			//sizeOfDocuments = 0;
			//documents = new List<Document>();
			//attachmentList = new List<AttachmentList>();
			//attachmentJsonString = '';
			this.buildAttachmentListJson();
		}

		if(this.emailEditorConfig[0].Allow_Document_Upload__c){
			buildAdditionalAttachmentList();
		}
		this.to = '<div style="color:red; width:50px; height:10px;">I am a bear</div>';
	}

	private void determineDefaultContent(){
		//if(this.whatId == null && this.emailEditorConfig[0].Use_Translatable_Default_Email_Content__c){
			//this.defaultContentLabel = this.emailEditorConfig[0].Translatable_Default_Email_Content__c;
			try {
				Component.Apex.OutputText output;
				output = new Component.Apex.OutputText();
				output.expressions.value = '{!$Label.' + this.emailEditorConfig[0].Translatable_Default_Email_Content__c + '}';
				//this.defaultContentLabel = String.valueOf(output.value);
				this.htmlValueOfSelectedEmailtemplate = String.valueOf(output.value);
			} catch(Exception e){
				system.debug('@@@@ calling determineDefaultContent - ERROR : ' + e.getMessage());
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, 'There is no custom label to use as default content!'));
			}
		//}
	}

	public SObject getRelatedRecord(){
		system.debug('@@@@ getRelatedRecord : ' + this.whatId);
		if(this.whatId != null){
			String objectName = this.whatId.getSObjectType().getDescribe().getName();
			String queryStr = 'SELECT Id, Name FROM ' + objectName + ' WHERE Id =: whatId LIMIT 1';
			SObject record = Database.query(queryStr);
			system.debug('@@@@ getRelatedRecord - objectName : ' + objectName);
			system.debug('@@@@ getRelatedRecord - queryStr : ' + queryStr);
			system.debug('@@@@ getRelatedRecord - record: ' + record);
			return record;
		}
		return null;
	}

	/*public void setSenderEmail(){
		if(String.isNotBlank(this.sender) && !this.sender.equals('No Org Wide Email found!')){
			List<String> parts = this.sender.split(',');
			this.sender = parts[0] + ' "<' + parts[1] + '>"';
			fromBinding = parts[1];
		}
	}*/

	/*public void buildEmailTemplateSelectionList(){
		this.emailTemplateSelectionList = new List<SelectOption>{new SelectOption('none', 'select a template')};
		this.emailTemplateMap = new Map<Id, EmailTemplate>([SELECT Id, Name, Body, HtmlValue, DeveloperName, Subject, TemplateType FROM EmailTemplate WHERE IsActive = true]);
		if(!this.emailTemplateMap.isEmpty()){
			for(Id et : this.emailTemplateMap.keySet()){
				this.emailTemplateSelectionList.add(new SelectOption(this.emailTemplateMap.get(et).Name, et));
			}
		}
	}

	public void determineSelectedEmailTemplate(){
		if(this.selectedEmailTemplateId != null){
			this.selectedEmailTemplate = this.emailTemplateMap.get(this.selectedEmailTemplateId);
			this.subject = this.selectedEmailTemplate.subject;

		}
	}*/

	public void buildObjectDropdown(){
		this.objectNames = new List<SelectOption>();
		//List<Schema.SObjectType> gd = Schema.getGlobalDescribe().Values();
		system.debug('@@@@ calling buildObjectDropdown - default object : ' + this.emailEditorConfig[0].Default_Object__c);
		if(this.emailEditorConfig[0].Default_Object__c != null && !this.emailEditorConfig[0].Default_Object__c.equals('none')){
			this.selectedObject = this.emailEditorConfig[0].Default_Object__c;
		} else {
			this.objectNames.add(new SelectOption('none', '--- Select an object ---'));
		}

		List<Schema.SObjectType> gd = ProcessInstance.TargetObjectId.getDescribe().getReferenceTo();
		System.debug('@@@@ calling buildObjectDropdown gd size : ' + gd.size());
		for(Schema.SObjectType f : gd){
			if(!f.getDescribe().CustomSetting){ 
				system.debug('@@@@ calling buildObjectDropdown LABEL : ' + f.getDescribe().getLabel());
				system.debug('@@@@ calling buildObjectDropdown NAME : ' + f.getDescribe().getName());
				this.objectNames.add(new SelectOption(f.getDescribe().getName(),f.getDescribe().getLabel()));
			}
		}
		System.debug('@@@@ calling buildObjectDropdown objectNames size : ' + objectNames.size());
	}

	public void buildRecipientTypeDropDown(){
		this.recipientTypes = new List<SelectOption>();
		this.recipientTypes.add(new SelectOption('none', '--- Select default Recipient type ---'));
		this.recipientTypes.add(new SelectOption('user', 'User'));
		this.recipientTypes.add(new SelectOption('contact', 'Contact'));
		this.recipientTypes.add(new SelectOption('lead', 'Lead'));
		system.debug('@@@@ calling buildRecipientTypeDropDown - default Recipient type : ' + this.emailEditorConfig[0].Default_Recipient_Type__c);
		if(this.emailEditorConfig[0].Default_Recipient_Type__c != null && !this.emailEditorConfig[0].Default_Recipient_Type__c.equals('none')){
			this.recipientType = this.emailEditorConfig[0].Default_Recipient_Type__c;
		}
	}

	public void buildFieldList(){
		system.debug('@@@@ calling buildFieldList - selectedObject : ' + this.selectedObject);
		system.debug('@@@@ calling buildFieldList - objectFields before : ' + this.objectFields);
		if(this.selectedObject != null){
			this.objectFields = new List<SelectOption>();
			SObjectType sType = Schema.getGlobalDescribe().get(this.selectedObject);
			Map<String,Schema.SObjectField> mfields = sType.getDescribe().fields.getMap();
			system.debug('@@@@ mfields : ' + mfields);
			for(Schema.SObjectField field : mfields.Values()){
			    system.debug('NName : ' + field.getDescribe().getName() + 'TType : ' + field.getDescribe().getType());
			    //if(field.getDescribe().getType().name().equals('PICKLIST') || field.getDescribe().getType().name().equals('STRING') || field.getDescribe().getType().name().equals('TEXTAREA') || field.getDescribe().getType().name().equals('EMAIL')){
			    if(field.getDescribe().getType().name().equals('PICKLIST') || field.getDescribe().getType().name().equals('STRING') || field.getDescribe().getType().name().equals('EMAIL')){
			    	this.objectFields.add(new SelectOption(field.getDescribe().getName(), field.getDescribe().getName()));
			    }
			}
		}
		system.debug('@@@@ calling buildFieldList - objectFields after : ' + this.objectFields);
	}

	public void buildTemplateDropdown(){
		//if(this.emailEditorConfig[0].Show_Folder_Selection__c){
			this.folders = new List<SelectOption>();
			this.folders.add(new SelectOption('none', '--- Select folder ---'));
			Map<String, String> folderMap = new Map<String, String>();
			for(EmailTemplate et : [SELECT Id, Name, Subject, TemplateType, FolderId, Folder.Name FROM EmailTemplate WHERE IsActive = true ORDER BY FolderId]){
				String fname = et.Folder.Name;
				if (String.valueOf(et.FolderId).substring(0,3) == '005'){
					fname = 'Personal Folder';
				} else if(String.valueOf(et.FolderId).substring(0,3) == '00D'){
					fname = 'Public Folder';
				}
				folderMap.put(et.FolderId, fname);
			}
			for(String str : folderMap.keySet()){
				this.folders.add(new SelectOption(str, folderMap.get(str)));
			}
		//}
	}

	public void determineSenderEmailAddresses(){
		this.senderDropdown = new List<SelectOption>();
		//List<String> senderList = new List<String>();
		if(this.emailEditorConfig[0].FromEmail_Default_RunningUser__c){
			//senderList.add(UserInfo.getUserEmail());
			this.sender = UserInfo.getName()+ '" <' +  UserInfo.getUserEmail() + '>';
			this.fromBinding = UserInfo.getUserEmail();
		} else if(this.emailEditorConfig[0].FromEmail_Default_OrgWideEmails__c){
			List<OrgWideEmailAddress> owea = [SELECT Id, DisplayName, Address, IsAllowAllProfiles FROM OrgWideEmailAddress WHERE Id =: this.emailEditorConfig[0].FromEmail_Default_OrgWideEmail_Text__c];
			if(!owea.isEmpty()){
				this.sender = owea[0].DisplayName + ' <' + owea[0].Address + '>';
				this.fromBinding = owea[0].Address;
			} else{
				this.determineOrgWideEmailAddresses(false);
				system.debug('@@@@ calling determineSenderEmailAddresses : ' + this.orgWideEmailAddresses);
				system.debug('@@@@ calling Selected Org Wide Email : ' + this.emailEditorConfig[0].FromEmail_Default_OrgWideEmail_Text__c);
				if(this.orgWideEmailAddresses != null && this.orgWideEmailAddresses.size() > 1){
					this.senderDropdown.add(new SelectOption('none', '-- Select sender --'));
					for(OrgWideEmailAddress owa : this.orgWideEmailAddresses){
						//senderList.add(owea.Address);
						this.senderDropdown.add(new SelectOption(owa.Id, ' "' + UserInfo.getOrganizationName()+ '" <' +  owa.Address + '>'));
					}
				} else if(this.orgWideEmailAddresses != null && this.orgWideEmailAddresses.size() == 1){
					this.sender = UserInfo.getOrganizationName() + '" <' +  this.orgWideEmailAddresses[0].Address + '>';
					this.fromBinding = this.orgWideEmailAddresses[0].Address;
				} else {
					this.sender = 'No Org Wide Email found!';
				}
			}
		} else if(this.emailEditorConfig[0].FromEmail_Default_Other__c){
			if(String.isNotBlank(this.emailEditorConfig[0].FromEmail_Default_Other_Text__c)){
				this.sender = this.emailEditorConfig[0].FromEmail_Default_Other_Text__c;
				this.fromBinding = this.emailEditorConfig[0].FromEmail_Default_Other_Text__c;
			} else{
				this.sender = 'use lookup to select sender!';
				showSenderLookup = true;
			}
		} else if(this.emailEditorConfig[0].FromEmail_Choose_At_Runtime__c){
			this.sender = 'use lookup to select sender!';
			showSenderLookup = true;
			/*this.senderDropdown.add(new SelectOption('none', '-- Select sender --'));
			this.senderDropdown.add(new SelectOption(Userinfo.getUserEmail(), ' "' + UserInfo.getName()+ '" <' +  UserInfo.getUserEmail() + '>'));
			this.determineOrgWideEmailAddresses(false);
			if(this.orgWideEmailAddresses != null){
				for(OrgWideEmailAddress owa : this.orgWideEmailAddresses){
					//senderList.add(owea.Address);
					this.senderDropdown.add(new SelectOption(owa.Id, ' "' + UserInfo.getOrganizationName()+ '" <' +  owa.Address + '>'));
				}
			}*/
		}
		//this.sender = String.join(senderList, ',');
	}

	// called when the save button on the lookup or the recipient table is clicked
	public void setCorrectRecipientList(){
		if(this.searchOption.equals('from')){
			this.sender = buildRecipientString(this.sender);
		} else if(this.searchOption.equals('to')){
			this.to = buildRecipientString(this.to);
		} else if(this.searchOption.equals('additionalTo')){
			this.additionalTo = buildRecipientString(this.additionalTo);
		} else if(this.searchOption.equals('cc')){
			this.cc = buildRecipientString(this.cc);
		} else if(this.searchOption.equals('bcc')){
			this.bcc = buildRecipientString(this.bcc);
		}
	}

	public String buildRecipientString(String existingStr){
		Set<String> recipientSet = new Set<String>();
		List<String> partsExistingStr = existingStr.split(',');
		List<String> lookupRecipients = this.emailAddressesFromLookUp.split(',');
		recipientSet.addAll(partsExistingStr);
		recipientSet.addAll(lookupRecipients);
		List<String> uniqueList = new List<String>(recipientSet);
		return String.join(uniqueList, ',');
	}

	private void setSelectedFolder(){
		if(emailEditorConfig[0].Allow_Template_Use__c && String.isNotBlank(emailEditorConfig[0].Default_Email_Folder__c)){
			List<String> parts = String.isNotBlank(emailEditorConfig[0].Default_Email_Folder__c) ? emailEditorConfig[0].Default_Email_Folder__c.split('_') : new List<String>();
			system.debug('@@@@ calling setSelectedFolder - parts : ' + parts);
			if(!parts.isEmpty()){
				//this.editorOptions.selectedDefaultFolder = parts[0];
				//system.debug('@@@@ calling setSelectedFolder - this.editorOptions.selectedDefaultFolder : ' + this.editorOptions.selectedDefaultFolder);
				selectedFolder = parts[0];
			} else {
				//this.editorOptions.selectedDefaultFolder = Userinfo.getOrganizationId();
				selectedFolder = Userinfo.getOrganizationId();
			}
		}
	}

	public List<SelectOption> getTemplateOptions() {
		List<SelectOption> options = new List<SelectOption>();
		//this.setSelectedFolder();
		system.debug('@@@@ calling getTemplateOptions - selectedFolder : ' + selectedFolder);
		if(emailEditorConfig[0].Allow_Template_Use__c && selectedFolder != null){			
			system.debug('@@@@ calling getTemplateOptions : ' + selectedFolder);
			options.add(new SelectOption('none', '--- Select Email Template ---'));
			for(EmailTemplate et : [SELECT Id, Name, HtmlValue FROM EmailTemplate WHERE FolderId = : selectedFolder]){
				options.add(new SelectOption(et.Id, et.Name));
			}
		}
        return options;
    }

    public void setRecipientAndRefreshTemplateBody(){
    	system.debug('@@@@ setRecipientAndRefreshTemplateBody - setRecipientAndRefreshTemplateBody : '+  this.selectedRecipientId);    	
    	/*if(this.whatId == null && this.selectedEmailTemplateId == null){
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, 'You can use a template to send your email by choosing a related record and then choosing a suitable template!'));
    	} else if(this.whatId == null){
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, 'You can use a template to send your email by choosing a related record!'));
    	} else if(this.selectedEmailTemplateId == null){
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, 'You can use a template to send your email by choosing a suitable template!'));
    	} else {
    		this.getTemplateBody();
    	}*/
    	if(this.whatId != null && this.selectedEmailTemplateId != null){
    		this.getTemplateBody();
    	}
    }

    public void getTemplateBody(){
    	system.debug('@@@@ getTemplateBody - whatId : '+  this.whatId);
    	system.debug('@@@@ getTemplateBody - selectedEmailTemplateId : '+  this.selectedEmailTemplateId);
    	system.debug('@@@@ getTemplateBody - selectedRecipientId : '+  this.selectedRecipientId);
    	
    	if(this.selectedEmailTemplateId != null && !this.selectedEmailTemplateId.equals('none')){
    		if(this.whatId != null){
    			ClsEmailTemplateProcessor cep;
    			if(this.selectedRecipientId != null){
    				system.debug('@@@@ getTemplateBody - selectedRecipientId not null : '+  this.selectedRecipientId);
    				cep = new ClsEmailTemplateProcessor(this.selectedEmailTemplateId, this.whatId, this.selectedRecipientId);
    			} else {
    				system.debug('@@@@ getTemplateBody - selectedRecipientId null : '+  this.selectedRecipientId);
    				cep = new ClsEmailTemplateProcessor(this.selectedEmailTemplateId, this.whatId);
    			}
    			List<String> templateInfo = cep.getEmailHtmlValue();
    			this.htmlValueOfSelectedEmailtemplate = templateInfo[0];
    			if(templateInfo.size() > 1){
    				this.subject = templateInfo[1];
    			}
    			system.debug('@@@@ getTemplateBody - htmlValueOfSelectedEmailtemplate : ' +  this.htmlValueOfSelectedEmailtemplate);
    			this.defaultContentLabel = null;
    		} else {
    			//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, 'In order to use a template, you need to supply a relatedTo!'));
    		}
    	} else {
    		this.htmlValueOfSelectedEmailtemplate = '';
    		//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, 'You can choose a template for your email'));
    	}
    }

    /*public List<SelectOption> getTemplateOptions() {
		List<SelectOption> options = new List<SelectOption>();
		system.debug('@@@@ calling getTemplateOptions - this.editorOptions.selectedDefaultFolder : ' + this.editorOptions.selectedDefaultFolder);
		if(emailEditorConfig[0].Allow_Template_Use__c && this.editorOptions.selectedDefaultFolder != null){			
			system.debug('@@@@ calling getTemplateOptions : ' + this.editorOptions.selectedDefaultFolder);
			options.add(new SelectOption('none', '--- Select Email Template ---'));
			for(EmailTemplate et : [SELECT Id, Name, HtmlValue FROM EmailTemplate WHERE FolderId = : this.editorOptions.selectedDefaultFolder]){
				options.add(new SelectOption(et.Id, et.Name));
			}
		}
        return options;
    }*/

    public void dummyCall(){
    	system.debug('@@@@ calling getTemplateOptions : ' + selectedFolder);
    }

	public List<SelectOption> getNumberOfRecipients(){
		List<SelectOption> numbers = new List<SelectOption>();
		for(Integer i = 1; i <= this.emailEditorConfig[0].Number_Of_More_Recipients__c; i++){
			numbers.add(new SelectOption(String.valueOf(i), String.valueOf(i)));
		}
		return numbers;
	}

	public void manageRecipientList(){
		if(!this.additionalRecipientsList.isEmpty()){
			List<AdditionalRecipients> control = new List<AdditionalRecipients>();
			
			for(Integer i = 0; i < this.additionalRecipientsList.size(); i++){
				this.additionalRecipientsList[i].position = i;
				control.add(this.additionalRecipientsList[i]);
			}

			this.additionalRecipientsList = new List<AdditionalRecipients>();
		
			for(Integer i = 0; i < control.size(); i++){
				if(i < this.selectedNumberToAdd){
					this.additionalRecipientsList.add(control[i]);
				}
			}
			if(recipientToRemove == null){
				if(this.additionalRecipientsList.size() < this.selectedNumberToAdd){
					for(Integer i = this.additionalRecipientsList.size(); i < this.selectedNumberToAdd; i++){
						this.additionalRecipientsList.add(new AdditionalRecipients('test_email@something.com', this.additionalRecipientsList.size()));
					}
				}
			}
			recipientToRemove = null;
		} else {
			for(Integer i = 0; i < this.selectedNumberToAdd; i++){
				this.additionalRecipientsList.add(new AdditionalRecipients('test_email@something.com', i));
			}
		}	
	}

	public void addRecipient(){
		AdditionalRecipients ar = new AdditionalRecipients('test_email@something.com', this.additionalRecipientsList.size());
		this.additionalRecipientsList.add(ar);
		this.selectedNumberToAdd = this.additionalRecipientsList.size();
	}

	public void removeRecipient(){
		if(recipientToRemove != null){
			this.additionalRecipientsList.remove(this.recipientToRemove);
			this.manageRecipientList();
		}
		this.selectedNumberToAdd = this.additionalRecipientsList.size();
	}

	public void sendEmail(){
		system.debug('@@@@ calling sendEmail - fromBinding : ' + this.fromBinding);
		system.debug('@@@@ calling sendEmail - toBinding : ' + this.toBinding);
		system.debug('@@@@ calling sendEmail - ccBinding : ' + this.ccBinding);
		system.debug('@@@@ calling sendEmail - bccBinding : ' + this.bccBinding);
		system.debug('@@@@ calling sendEmail - content : ' + this.htmlValueOfSelectedEmailtemplate);
		system.debug('@@@@ calling sendEmail - subject : ' + this.subject);
		system.debug('@@@@ calling sendEmail - additionalTo : ' + this.additionalTo);
		system.debug('@@@@ calling sendEmail - Size : ' + this.additionalAttachments.size());
		/*Set<String> emailAddresses = this.determineAllEmailAddresses();
		Set<String> wrongEmailAddresses = this.validateEmailAddressMatcher(emailAddresses);
		if(!wrongEmailAddresses.isEmpty()){
			String errorMessage = 'Please correct the following email addresses and try again <br /> <ul>';
			for(String str : wrongEmailAddresses){
				errorMessage += '<li>' + str + '</li>';
			}
			errorMessage += '</ul>';
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, errorMessage));
			return null;
		}*/

		List<Attachment> allEmailAttachments = new List<Attachment>();

		if(this.attachmentsToUpload == null){  
           this.attachmentsToUpload = new List<Attachment>();  
           this.attachmentNamesNew = new List<String>();
           this.attachmentNamesOld = new List<String>();
	    }  
	    

		for(AdditionalAttachments att : this.additionalAttachments){
			if(att.record.body != null){
				this.attachmentNamesNew.add(att.record.Name);  
                attachmentsToUpload.add(att.record); 
				allEmailAttachments.add(att.record);
			}
		}

		/*if(attachmentJsonString != null && String.isNotBlank(attachmentJsonString)){
			List<Attachment> atts = (List<Attachment>)JSON.deserialize(attachmentJsonString, List<Attachment>.class);
			for(Attachment att : atts){
				this.attachmentNamesOld.add(att.Name);  
				allEmailAttachments.add(att);
			}
		}*/

		if(this.selectedAttsBinding != null && String.isNotBlank(selectedAttsBinding)){
			List<String> attList = this.selectedAttsBinding.split(',');
			system.debug('@@@@ sendEmail attList :' + attList);
			List<Attachment> atts = [SELECT Id, Name, Body, BodyLength, ContentType FROM Attachment WHERE Id IN: attList];
			for(Attachment att : atts){
				this.attachmentNamesOld.add(att.Name);  
				allEmailAttachments.add(att);
			}
		}
		

		system.debug('@@@@ sendEmail attachmentNamesNew :' + attachmentNamesNew);
		system.debug('@@@@ sendEmail attachmentNamesOld :' + attachmentNamesOld);
		system.debug('@@@@ sendEmail selectedDocsBinding :' + selectedDocsBinding);
		system.debug('@@@@ sendEmail selectedAttsBinding :' + selectedAttsBinding);
		
 
    	this.buildEmailFileAttachments(allEmailAttachments);


		this.additionalAttachments = null;
		this.buildAdditionalAttachmentList();
		this.showEmailEditor = false;
		/*String sendMore = '<apex:outputLink target="_self" value="/apex/EmailEditor';
		//if(whatId != null && String.isNotBlank(whatId) && !whatId.equals('none')){
		if(this.whatId != null && this.whatId != 'none'){
			sendMore += '/recordId=' + this.whatId;
		}
		sendMore += '" >Send more</apex:outputLink>';*/
		/*String sendMore = '';
		if(this.whatId != null){
			sendMore = '<b><a href="/apex/EmailEditor?recordId=' + this.whatId + '" target="_parent"> Send More </a></b>';
		} else {
			sendMore = '<b><a href="/apex/EmailEditor" target="_parent"> Send More </a></b>';
		}
		
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Your email was sent successfully. ' + sendMore));*/

		performSendOperation();
		//return null;
	}

	public void performSendOperation(){
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		if(this.toBinding != null && String.isNotBlank(this.toBinding)){
			mail.setToAddresses(this.toBinding.split(','));
		}
		if(this.ccBinding != null && String.isNotBlank(this.ccBinding)){
			mail.setCcAddresses(this.ccBinding.split(','));
		}
		if(this.bccBinding != null && String.isNotBlank(this.bccBinding)){
			mail.setBccAddresses(this.bccBinding.split(','));
		}
        
        
       

        /*Optional. The name that appears on the From line of the email. This cannot be set if the object associated with a setOrgWideEmailAddressId for a SingleEmailMessage has defined its DisplayName field.*/
        if(this.emailEditorConfig[0].FromEmail_Default_OrgWideEmails__c && this.emailEditorConfig[0].FromEmail_Default_OrgWideEmail_Text__c != null){
        	/* Optional. The ID of the organization-wide email address associated with the outgoing email. The object's DisplayName field cannot be set if the setSenderDisplayName field is already set.*/
        	//mail.setSenderDisplayName(this.emailEditorConfig[0].FromEmail_Default_OrgWideEmail_Text__c);
        	mail.setOrgWideEmailAddressId((Id)this.emailEditorConfig[0].FromEmail_Default_OrgWideEmail_Text__c) ;
    	} else {
    		if(this.sender != null){
    			mail.setSenderDisplayName(this.sender);
    		}
    	}

    	
    	/* The ID of the template to be merged to create this email. You must specify a value for setTemplateId, setHtmlBody, or setPlainTextBody. Or, you can define both setHtmlBody and setPlainTextBody. */
        if(this.selectedEmailTemplateId != null && String.isNotBlank(this.selectedEmailTemplateId) && !this.selectedEmailTemplateId.equals('none')){
            mail.setTemplateId(this.selectedEmailTemplateId);
        } else{
        	mail.setSubject(this.subject);
        	if(this.htmlValueOfSelectedEmailtemplate != null && String.isNotBlank(this.htmlValueOfSelectedEmailtemplate)){
	    		mail.setHtmlBody(this.htmlValueOfSelectedEmailtemplate);
	    	} else {
	    		mail.setPlainTextBody('');
	    	}
        }

        /* Optional. If you specify a contact for the targetObjectId field, you can specify a whatId as well. This helps to further ensure that merge fields in the template contain the correct data.*/
        if(this.selectedRecipientId != null && this.selectedRecipientId != 'none'){
        	if(!((Id)this.selectedRecipientId).getSObjectType().getDescribe().getName().equals('User') && this.whatId != null){
        		mail.setWhatId(this.whatId);
        	}
        	/* Required if using a template, optional otherwise. The ID of the contact, lead, or user to which the email will be sent. The ID you specify sets the context and ensures that merge fields in the template contain the correct data.*/
        	mail.setTargetObjectId((Id)this.selectedRecipientId);

        	/* Optional. The default value is true, meaning the email is saved as an activity. This argument only applies if the recipient list is based on targetObjectId or targetObjectIds. If HTML email tracking is enabled for the organization, you will be able to track open rates.*/
        	if(this.emailEditorConfig[0].Save_As_Activity__c && this.whatId != null){
	    		mail.setSaveAsActivity(true);
	    	}
    	} else if(this.whatId != null){
    		mail.setWhatId(this.whatId);
    	}


        mail.setUseSignature(false);
        if(this.emailEditorConfig[0].Allow_Document_Upload__c && this.selectedDocsBinding != null){
        	mail.setDocumentAttachments(this.selectedDocsBinding.split(',')); 
        }
    	

    	
    	mail.setFileAttachments(this.emailAttachmentsToSend);

    	try{
    		system.debug('@@@@ performSendOperation - mail ' + mail);
    		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

    		if(this.emailEditorConfig[0].Save_As_Activity__c && this.whatId != null && this.selectedRecipientId != null && this.selectedRecipientId != 'none'){
	    		createCompletedTask();
	    	}

    		String sendMore = '';
			if(this.whatId != null){
				sendMore = '<b><a href="/apex/EmailEditor?recordId=' + this.whatId + '" target="_parent"> Send More </a></b>';
			} else {
				sendMore = '<b><a href="/apex/EmailEditor" target="_parent"> Send More </a></b>';
			}
			
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Your email was sent successfully. ' + sendMore));
    		
		} catch(Exception e){
			System.debug('The following error occurred while sending email : ' + e.getMessage());
		}
	}

	private void buildEmailFileAttachments(List<Attachment> allEmailAttachments){
		if(this.emailAttachmentsToSend == null){  
	        this.emailAttachmentsToSend = new List<Messaging.Emailfileattachment>();  
	    }
		for(Attachment att : allEmailAttachments){  
           Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();  
           efa.setBody(att.Body);  
           efa.setFileName(att.Name);  
           efa.setContentType(att.ContentType);  
           this.emailAttachmentsToSend.add(efa);  
      	}
	}


	public Id createCompletedTask(){  
      	Id taskId;  
      	String comment = 'Email Recipients: <br /> To: ' + this.toBinding + '<br /> Cc: ';
      	comment += this.ccBinding != null ? this.ccBinding +  ' <br /> Bcc: ' : ' <br /> Bcc: ' ;
      	comment += this.bccBinding != null ? this.bccBinding +  ' <br />' : ' <br />' ;
      	comment += 'Email Content: ' + this.htmlValueOfSelectedEmailtemplate;

      	List<TaskStatus> ts = [SELECT MasterLabel, IsClosed FROM TaskStatus WHERE IsClosed = true];

      	Task completedTask = new Task();  
      	completedTask.Subject = 'Email Editor Log';  
      	completedTask.Status = ts[0].MasterLabel;  
      	completedTask.Priority = 'Normal';  
      	completedTask.Type = 'Email';  
      	completedTask.OwnerId = Userinfo.getUserId(); 
      	completedTask.WhatId = this.whatId;  
      	completedTask.ActivityDate = Date.today(); 

      	completedTask.Description = comment;  
      	try{  
        	Database.Saveresult result = Database.insert(completedTask);  
           	if(result.isSuccess()){  
                taskId = result.getId();  
           	}       
           	return taskId;  
      	} catch(Exception e){  
           	Apexpages.Message pmessage = new Apexpages.Message(Apexpages.Severity.ERROR, 'A task was not inserted for this Opportunity Report. Please contact your admin.');  
           	Apexpages.addMessage(pMessage);  
           	return null;  
      	}  
 	}


 	/*public void createAttachmentsForTask(Id taskId){  
      	if(this.attachmentsToUpload != null){  
           	if(!this.attachmentsToUpload.isEmpty()){  
                for(Attachment att : this.attachmentsToUpload){       
                     att.ParentId = taskId;  
                }  
           	}  
           	try{  
                insert this.attachmentsToUpload;  
           	} catch (Exception e){  
                Apexpages.Message pmessage = new Apexpages.Message(Apexpages.Severity.ERROR, 'The following error occured while adding attachments to the created task: ' + e);  
                Apexpages.addMessage(pMessage);  
           	}  
      	}  
 	}*/  
	/*private Set<String> determineAllEmailAddresses(){
		Set<String> emailAddresses = new Set<String>();
		if(this.toBinding != null && String.isNotBlank(this.toBinding)){
			emailAddresses.addAll(this.toBinding.split(','));
		}
		if(this.ccBinding != null && String.isNotBlank(this.ccBinding)){
			emailAddresses.addAll(this.ccBinding.split(','));
		}
		if(this.bccBinding != null && String.isNotBlank(this.bccBinding)){
			emailAddresses.addAll(this.bccBinding.split(','));
		}
		return emailAddresses;
	}

	private Set<String> validateEmailAddressMatcher(Set<String> emailAddresses){  
      	Set<String> wrongEmailAddresses = new Set<String>();  
      	String regEx = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';  
      	Pattern emailPattern = Pattern.compile(regEx);  
      	try{  
           for(String email : emailAddresses){  
                Matcher emailMatcher = emailPattern.matcher(email);  
                if(!emailMatcher.matches()){  
                     wrongEmailAddresses.add(email);  
                }  
           }  
      	} catch(Exception e){  
           wrongEmailAddresses.add('Error occured');  
      	}  
      	return wrongEmailAddresses;  
 	} */

	public void cancel(){

	}

	public void buildAttachmentListJson(){
		//List<AttachmentList> attachmentList = new List<AttachmentList>();
		system.debug('@@@@ calling buildAttachmentListJson - whatId : ' + this.whatId);
		List<Attachment> atts = [SELECT Id, Name, BodyLength, ContentType FROM Attachment WHERE ParentId =: this.whatId];
		/*String parentId = '006i000000HFessAAD';
		List<Attachment> atts = [SELECT Id, Name, BodyLength, ContentType FROM Attachment WHERE ParentId =: parentId];*/
		
		attachmentJsonString = JSON.serializePretty(atts);	
		system.debug('@@@@ buildAttachmentListJson - attachmentJsonString' + attachmentJsonString);
	}

	public void buildAdditionalAttachmentList(){
        this.additionalAttachments = new List<AdditionalAttachments>();
        //this.attachmentsToUpload = new List<Attachment>();
        Integer numberOfAttachments = Integer.valueOf(this.emailEditorConfig[0].Number_Of_Documents_To_Upload__c);
        for(Integer i= 0; i<numberOfAttachments; i++){
            this.additionalAttachments.add(new AdditionalAttachments(new Attachment(), i));
        }
    }

	public class AdditionalRecipients{
		public Integer position { get; set; }
		public Boolean to { get; set; }
		//public Boolean additionalTo { get; set; }
		public Boolean cc { get; set; }
		public Boolean bcc { get; set; }
		public String email { get; set; }

		public AdditionalRecipients(String email, Integer position){
			this.position = position;
			this.to = false;
			//this.additionalTo = false;
			this.cc = false;
			this.bcc = false;
			this.email  = email;
		}
	}

	public class AdditionalAttachments{

		//public Boolean saveAsDocument { get; set; }
		public Integer position { get; set; }
		public Attachment record { get; set; }

		public AdditionalAttachments(Attachment att, Integer position){
			this.record = att;
			this.position = position;
		}
	}

	public class AttachmentList{
		public Boolean selected { get; set; }
		public String attachmentName { get; set; }
		public String attachmentId { get; set; }
		public Integer docSize { get; set; }
		public AttachmentList(Attachment att){
			this.attachmentName = att.Name;
			this.attachmentId = att.Id;
			this.docSize = att.BodyLength;
		}
	}
}