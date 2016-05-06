public with sharing class CtrEmailEditorConfiguration extends ClsEmailEditorOptions {

	public CtrEmailEditorConfiguration() {
		this.determineOptions();
	}

	public void save(){
		if(this.emailEditorConfig != null){
			if(this.toEmailOption != null){
				if(this.toEmailOption.equals('user_only')){
					this.emailEditorConfig[0].RecipientEmail_Users_Only__c = true;
					this.emailEditorConfig[0].RecipientEmail_Contacts_Only__c = false;
					this.emailEditorConfig[0].RecipientEmail_Both_Only__c = false;
				} else if(this.toEmailOption.equals('contact_only')) {
					this.emailEditorConfig[0].RecipientEmail_Contacts_Only__c = true;
					this.emailEditorConfig[0].RecipientEmail_Both_Only__c = false;
					this.emailEditorConfig[0].RecipientEmail_Users_Only__c = false;
				} else if(this.toEmailOption.equals('to_both')){
					this.emailEditorConfig[0].RecipientEmail_Both_Only__c = true;
					this.emailEditorConfig[0].RecipientEmail_Contacts_Only__c = false;
					this.emailEditorConfig[0].RecipientEmail_Users_Only__c = false;
				}
			}

			if(this.senderOption != null){
				if(this.senderOption.equals('user_only')){
					this.emailEditorConfig[0].FromEmail_User_Only__c = true;
					this.emailEditorConfig[0].FromEmail_Both_Only__c = false;
					this.emailEditorConfig[0].FromEmail_OrgWide_Only__c = false;
				} else if(this.senderOption.equals('org_wide_only')) {
					this.emailEditorConfig[0].FromEmail_OrgWide_Only__c = true;
					this.emailEditorConfig[0].FromEmail_User_Only__c = false;
					this.emailEditorConfig[0].FromEmail_Both_Only__c = false;
				} else if(this.senderOption.equals('from_both')){
					this.emailEditorConfig[0].FromEmail_Both_Only__c = true;
					this.emailEditorConfig[0].FromEmail_User_Only__c = false;
					this.emailEditorConfig[0].FromEmail_OrgWide_Only__c = false;
				} 
			}

			if(this.defaultSenderOption != null){
				system.debug('@@@@ calling save - defaultSenderOption : ' + this.defaultSenderOption);
				if(this.defaultSenderOption.equals('default_user')){
					this.emailEditorConfig[0].FromEmail_Default_RunningUser__c = true;
					this.emailEditorConfig[0].FromEmail_Default_OrgWideEmails__c = false;
					this.emailEditorConfig[0].FromEmail_Choose_At_Runtime__c = false;
					this.emailEditorConfig[0].FromEmail_Default_Other__c = false;
				} else if(this.defaultSenderOption.equals('default_org')) {
					this.emailEditorConfig[0].FromEmail_Default_OrgWideEmails__c = true;
					this.emailEditorConfig[0].FromEmail_Default_RunningUser__c = false;
					this.emailEditorConfig[0].FromEmail_Choose_At_Runtime__c = false;
					this.emailEditorConfig[0].FromEmail_Default_Other__c = false;
				} else if(this.defaultSenderOption.equals('select_runtime')){
					this.emailEditorConfig[0].FromEmail_Choose_At_Runtime__c = true;
					this.emailEditorConfig[0].FromEmail_Default_RunningUser__c = false;
					this.emailEditorConfig[0].FromEmail_Default_OrgWideEmails__c = false;
					this.emailEditorConfig[0].FromEmail_Default_Other__c = false;
				} else if(this.defaultSenderOption.equals('other')){
					this.emailEditorConfig[0].FromEmail_Default_Other__c = true;
					this.emailEditorConfig[0].FromEmail_Choose_At_Runtime__c = false;
					this.emailEditorConfig[0].FromEmail_Default_RunningUser__c = false;
					this.emailEditorConfig[0].FromEmail_Default_OrgWideEmails__c = false;
				}
			}

			if(this.uiOption != null){
				if(this.uiOption.equals('lookup_only')){
					this.emailEditorConfig[0].Use_Lookups_Only__c = true;
					this.emailEditorConfig[0].Use_Single_Table_Only__c = false;
				} else if(this.uiOption.equals('table_only')){
					this.emailEditorConfig[0].Use_Single_Table_Only__c = true;
					this.emailEditorConfig[0].Use_Lookups_Only__c = false;
				}
			}

			/*if(this.attachmentOpt != null){
				if(this.attachmentOpt.equals('att_selection')){
					this.emailEditorConfig[0].Allow_Attachment_Selection__c = true;
					this.emailEditorConfig[0].Automatically_Attach_Documents__c = false;
				} else if(this.attachmentOpt.equals('automatic_attach')){
					this.emailEditorConfig[0].Allow_Attachment_Selection__c = false;
					this.emailEditorConfig[0].Automatically_Attach_Documents__c = true;
				}
			}*/

			//this.emailEditorConfig[0].Add_More_Recipents__c = this.moreRecipients;
			//this.emailEditorConfig[0].Number_Of_More_Recipients__c = this.possibleNumberOfAdditionalRecipients;
			this.emailEditorConfig[0].Show_Options_On_Page__c = this.showOptionsOnEditor;
			/*this.emailEditorConfig[0].FromEmail_Default_RunningUser__c = this.runningUserAsDefaultSender;
			this.emailEditorConfig[0].FromEmail_Default_OrgWideEmails__c = this.orgWideEmailAsDefaultSender;*/
			//this.emailEditorConfig[0].Use_Translatable_Default_Email_Content__c = this.useTranslatableDefaultContent;
			//this.emailEditorConfig[0].Show_Add_Attachment_Section__c = this.letUsersAttachDocuments;
			//this.emailEditorConfig[0].Attach_Documents_From_Record__c = this.attachDocumentsFromRecords;
			this.emailEditorConfig[0].Default_Email_Folder__c = this.selectedDefaultFolder;
			this.emailEditorConfig[0].Default_Object__c = this.selectedObject;
			this.emailEditorConfig[0].Number_Of_Documents_To_Upload__c = this.numberOfFilesToUpload;
			this.emailEditorConfig[0].Default_Recipient_Type__c = this.defaultRecipientType;

			/*if(String.isNotBlank(this.selectedDefaultFolder)){
				this.emailEditorConfig[0].Default_Email_Folder__c = this.selectedDefaultFolder;
			}*/

			/*if(String.isNotBlank(this.defaultContentLabel)){
				this.emailEditorConfig[0].Translatable_Default_Email_Content__c = this.defaultContentLabel;
			}*/

			if(String.isNotBlank(this.orgWideEmail) && !this.orgWideEmail.equals('none')){
				this.emailEditorConfig[0].FromEmail_Default_OrgWideEmail_Text__c =  this.orgWideEmail;
			}

			system.debug('@@@@ calling save : ' + this.emailEditorConfig[0].FromEmail_Default_Other_Text__c );
			try {
				update this.emailEditorConfig;
			} catch(Exception e){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'An error occured while saving your settings. Please contact your admin!'));
				System.debug('@@@@ calling saveSettings. The following error occured while saving the editor email settings: ' + e.getMessage());
			}
		}
	}

	public void cancel(){

	}
}