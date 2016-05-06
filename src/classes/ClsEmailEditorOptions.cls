public virtual with sharing class ClsEmailEditorOptions {

	public List<EmailEditorConfiguration__c> emailEditorConfig { get; set; }
	public String senderOption { get; set; }
	public List<SelectOption> senderOptions { get; set; }
	public String defaultSenderOption { get; set; }
	public List<SelectOption> defaultSenderOptions { get; set; }
	public List<SelectOption> defaultFolder { get; set; }
	public List<SelectOption> defaultRecipientTypeOptions { get; set; }
	public String defaultRecipientType { get; set; }
	public String selectedDefaultFolder { get; set; }
	/*public Boolean runningUserAsDefaultSender { get; set; }
	public Boolean orgWideEmailAsDefaultSender { get; set; }*/
	public String toEmailOption { get; set; }
	public List<SelectOption> toEmailOptions { get; set; }
	public String uiOption { get; set; }
	public List<SelectOption> uiOptions { get; set; }
	//public String defaultContentLabel { get; set; }
	//public Boolean useTranslatableDefaultContent { get; set; }

	//public Boolean moreRecipients { get; set; }
	public Boolean showOptionsOnEditor { get; set; }
	//public Decimal possibleNumberOfAdditionalRecipients { get; set; }
	//public Boolean attachDocumentsFromRecords { get; set; }
	//public Boolean letUsersAttachDocuments { get; set; }

	//public List<SelectOption> attachmentOptions { get; set; }
	public String attachmentOpt { get; set; }

	public String selectedObject { get; set; }
	public List<SelectOption> objectNames { get; set; }
	public Decimal numberOfFilesToUpload { get; set; }

	public List<SelectOption> orgWideEmails { get; set; }
	public String orgWideEmail { get; set; }
	public Boolean orgWideEmailExist { get; set; }
	public Boolean orgWideEmailDoesNotExist { get; set; }

	public ClsEmailEditorOptions() {
		this.emailEditorConfig = EmailEditorConfiguration__c.getall().values();
		//this.defaultSettings();
		this.orgWideEmailDoesNotExist = false;
		if(this.emailEditorConfig[0].FromEmail_Default_OrgWideEmail_Text__c != null){
			this.orgWideEmail = this.emailEditorConfig[0].FromEmail_Default_OrgWideEmail_Text__c;
		} else {
			this.orgWideEmail ='none';
		}
		
		system.debug('@@@@ calling CtrEmailEditorConfiguration - emailEditorConfig : ' + this.emailEditorConfig);
	}

	public void determineOptions(){
		this.determineSenderOptions();
		this.determineDefaultSenderOptions();
		this.determineToEmailOptions();
		this.determineDefaultFolderOptions();
		this.determineUiOptions();
		this.buildObjectDropdown();
		this.determineDefaultRecipientType();
		this.determineOrgWideEmailAddresses();
		//determineAttachmentOptions();
		this.defaultSettings();
	}

	public void determineOptionsForPage(){
		this.determineSenderOptions();
		this.determineDefaultSenderOptions();
		this.determineToEmailOptions();
		//this.determineDefaultFolderOptions();
		this.determineUiOptions();
		this.defaultSettings();
	}

	public void buildObjectDropdown(){
		this.objectNames = new List<SelectOption>();
		system.debug('@@@@ calling buildObjectDropdown - default object : ' + this.emailEditorConfig[0].Default_Object__c);
		//if(!String.isNotBlank(this.emailEditorConfig[0].Default_Object__c) && !this.emailEditorConfig[0].Default_Object__c.equals('none')){
			this.selectedObject = this.emailEditorConfig[0].Default_Object__c;
		/*} else {
			this.objectNames.add(new SelectOption('none', '--- None ---'));
		}*/
		List<Schema.SObjectType> gd = ProcessInstance.TargetObjectId.getDescribe().getReferenceTo();
		for(Schema.SObjectType f : gd){
			if(!f.getDescribe().CustomSetting){ 
				this.objectNames.add(new SelectOption(f.getDescribe().getLabel(),f.getDescribe().getLabel()));
			}
		}
	}

	public void determineDefaultFolderOptions(){
		this.defaultFolder = new List<SelectOption>();
		this.defaultFolder.add(new SelectOption('none', '--- Select default folder ---'));
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
			this.defaultFolder.add(new SelectOption(str + '_' + folderMap.get(str), folderMap.get(str)));
		}
	}

	public void determineSenderOptions(){
		this.senderOptions = new List<SelectOption>(); 
		this.senderOptions.add(new SelectOption('user_only', 'User Emails only'));
		this.senderOptions.add(new SelectOption('org_wide_only', 'Org Wide Emails only'));
		this.senderOptions.add(new SelectOption('from_both', 'Both User and Org Wide Emails'));
	}

	public void determineDefaultSenderOptions(){
		this.defaultSenderOptions = new List<SelectOption>(); 
		this.defaultSenderOptions.add(new SelectOption('default_user', 'Running user is default sender'));
		this.defaultSenderOptions.add(new SelectOption('default_org', 'Org wide Email is default sender'));
		this.defaultSenderOptions.add(new SelectOption('select_runtime', 'Select sender at runtime'));
		this.defaultSenderOptions.add(new SelectOption('other', 'Other'));
	}

	public void determineToEmailOptions(){
		this.toEmailOptions = new List<SelectOption>(); 
		this.toEmailOptions.add(new SelectOption('user_only', 'User Emails only'));
		this.toEmailOptions.add(new SelectOption('contact_only', 'Contact Emails only'));
		this.toEmailOptions.add(new SelectOption('to_both', 'Both User and Contact Emails'));
	}

	public void determineUiOptions(){
		this.uiOptions = new List<SelectOption>(); 
		this.uiOptions.add(new SelectOption('lookup_only', 'Add recipients via lookup'));
		this.uiOptions.add(new SelectOption('table_only', 'Add recipients from single table'));
	}

	public void determineDefaultRecipientType(){
		this.defaultRecipientTypeOptions = new List<SelectOption>(); 
		this.defaultRecipientTypeOptions.add(new SelectOption('none', '--- Select default Recipient type ---'));
		this.defaultRecipientTypeOptions.add(new SelectOption('user', 'User'));
		this.defaultRecipientTypeOptions.add(new SelectOption('contact', 'Contact'));
		this.defaultRecipientTypeOptions.add(new SelectOption('lead', 'Lead'));
	}

	public void determineOrgWideEmailAddresses(){
		this.orgWideEmails = new List<SelectOption>();
		List<OrgWideEmailAddress> orgWideEmailAddresses = [SELECT Id, DisplayName, Address, IsAllowAllProfiles FROM OrgWideEmailAddress];
		if(orgWideEmailAddresses.isEmpty()){
			orgWideEmailDoesNotExist = true;
		} else {
			this.orgWideEmails.add(new SelectOption('none', '--- Select Email ---'));
			for(OrgWideEmailAddress owea : orgWideEmailAddresses){
				String str = owea.DisplayName + ' <' + owea.Address + '>';
				this.orgWideEmails.add(new SelectOption(owea.Id, str));
			}
		}

	}
	/*public void determineAttachmentOptions(){
		this.attachmentOptions = new List<SelectOption>();
		this.attachmentOptions.add(new SelectOption('att_selection', 'allow attachment selection'));
		this.attachmentOptions.add(new SelectOption('automatic_attach', 'automatically attach all documents on record'));
	}*/

	public void defaultSettings(){
		if(this.emailEditorConfig[0].FromEmail_User_Only__c){
			this.senderOption = 'user_only';
		} else if(this.emailEditorConfig[0].FromEmail_OrgWide_Only__c){
			this.senderOption = 'org_wide_only';
		} else if(this.emailEditorConfig[0].FromEmail_Both_Only__c){
			this.senderOption = 'from_both';
		} else {
			this.senderOption = 'from_both';
		}

		if(this.emailEditorConfig[0].FromEmail_Default_RunningUser__c){
			this.defaultSenderOption = 'default_user';
		} else if(this.emailEditorConfig[0].FromEmail_Default_OrgWideEmails__c){
			this.defaultSenderOption = 'default_org';
		} else if(this.emailEditorConfig[0].FromEmail_Default_Other__c){
			this.defaultSenderOption = 'other';
		} else if(this.emailEditorConfig[0].FromEmail_Choose_At_Runtime__c){
			this.defaultSenderOption = 'select_runtime';
		}else {
			this.defaultSenderOption = 'select_runtime';
		}

		if(this.emailEditorConfig[0].RecipientEmail_Users_Only__c){
			this.toEmailOption = 'user_only';
		} else if(this.emailEditorConfig[0].RecipientEmail_Contacts_Only__c){
			this.toEmailOption = 'contact_only';
		} else if(this.emailEditorConfig[0].RecipientEmail_Both_Only__c){
			this.toEmailOption = 'to_both';
		} else {
			this.toEmailOption = 'to_both';
		}

		if(this.emailEditorConfig[0].Use_Lookups_Only__c){
			this.uiOption = 'lookup_only';
		} else if(this.emailEditorConfig[0].Use_Single_Table_Only__c){
			this.uiOption = 'table_only';
		} else {
			this.uiOption = 'lookup_only';
		}

		if(this.emailEditorConfig[0].Allow_Attachment_Selection__c){
			this.attachmentOpt = 'att_selection';
		} else if(this.emailEditorConfig[0].Automatically_Attach_Documents__c) {
			this.attachmentOpt = 'automatic_attach';
		}

		//this.moreRecipients = this.emailEditorConfig[0].Add_More_Recipents__c;
		//this.possibleNumberOfAdditionalRecipients = this.emailEditorConfig[0].Number_Of_More_Recipients__c;
		this.showOptionsOnEditor = this.emailEditorConfig[0].Show_Options_On_Page__c;
		//this.useTranslatableDefaultContent = this.emailEditorConfig[0].Use_Translatable_Default_Email_Content__c;
		//this.defaultContentLabel = this.emailEditorConfig[0].Translatable_Default_Email_Content__c;
		//this.attachDocumentsFromRecords = this.emailEditorConfig[0].Attach_Documents_From_Record__c;
		//this.letUsersAttachDocuments = this.emailEditorConfig[0].Show_Add_Attachment_Section__c;
		this.selectedDefaultFolder = this.emailEditorConfig[0].Default_Email_Folder__c;
		this.numberOfFilesToUpload = this.emailEditorConfig[0].Number_Of_Documents_To_Upload__c;
		this.defaultRecipientType = this.emailEditorConfig[0].Default_Recipient_Type__c;
	}

}