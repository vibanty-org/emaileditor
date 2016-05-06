public virtual with sharing class ClsEmailEditorBase {
	public List<User> userRecipients { get; set; }
	public List<Contact> contactRecipients { get; set; }
	public List<OrgWideEmailAddress> orgWideEmailAddresses { get; set; } // The object's DisplayName field cannot be set if the setSenderDisplayName field is already set.
	public List<OpportunityContactRole> oppContactRoleRecipeints { get; set; }
	public List<AccountContactRole> accountContactRoleRecipients { get; set; } 
	public List<EmailEditorConfiguration__c> emailEditorConfig { get; set; }
	public Map<String, List<EmailRecipientWrapper>> emailAddresses { get; set; }
	public String title { get; set; }
	public String selectedAddresses { get; set; }
	public Map<String, String> selectedAddressesMap { get; set; }

	public String selectedToAddresses { get; set; }
	public String selectedCcAddresses { get; set; }
	public String selectedBccAddresses { get; set; }
	public Map<String, List<Boolean>> selectedRecipientAddressesMap { get; set; }

	public ClsEmailEditorBase() {
		this.emailEditorConfig = EmailEditorConfiguration__c.getall().values();
		emailAddresses = new Map<String, List<EmailRecipientWrapper>>();
		this.selectedAddressesMap = new Map<String,String>();
		this.selectedRecipientAddressesMap = new Map<String, List<Boolean>>();
	}

	public void buildEmailForSelectedAddresses(){
		if(String.isNotBlank(this.selectedAddresses)){
			List<String> emailAddresses = this.selectedAddresses.split(',');
			for(String ea : emailAddresses){
				this.selectedAddressesMap.put(ea, ea);
			}
		}
	}

	// Used when a single table is used to select recipient addresses
	public void buildEmailForSelectedRecipientAddresses(){
		if(String.isNotBlank(this.selectedToAddresses)){
			List<String> emailAddresses = this.selectedToAddresses.split(',');
			for(String ea : emailAddresses){
				this.selectedRecipientAddressesMap.put(ea, new List<Boolean>{true, false, false});
			}
		}
		if(String.isNotBlank(this.selectedCcAddresses)){
			List<String> emailAddresses = this.selectedCcAddresses.split(',');
			for(String ea : emailAddresses){
				if(this.selectedRecipientAddressesMap.get(ea) != null){
					this.selectedRecipientAddressesMap.put(ea, new List<Boolean>{true, true, false});
				} else{
					this.selectedRecipientAddressesMap.put(ea, new List<Boolean>{false, true, false});
				}
			}
		}
		if(String.isNotBlank(this.selectedBccAddresses)){
			List<String> emailAddresses = this.selectedBccAddresses.split(',');
			for(String ea : emailAddresses){
				if(this.selectedRecipientAddressesMap.get(ea) != null){
					List<Boolean> vals = this.selectedRecipientAddressesMap.get(ea);
					this.selectedRecipientAddressesMap.put(ea, new List<Boolean>{vals[0], vals[1], true});
				} else{
					this.selectedRecipientAddressesMap.put(ea, new List<Boolean>{false, false, true});
				}
			}
		}
	}

	public void determineOrgWideEmailAddresses(Boolean flag){
		this.orgWideEmailAddresses = [SELECT Id, DisplayName, Address, IsAllowAllProfiles FROM OrgWideEmailAddress];
		system.debug('@@@@ calling determineOrgWideEmailAddresses - this.orgWideEmailAddresses : ' + this.orgWideEmailAddresses);
		this.addToRecipientList(this.orgWideEmailAddresses, flag);
	}

	public void determineUserRecipients(Boolean flag){
		this.userRecipients = [SELECT Id, Name, Email FROM User WHERE Email != null];
		system.debug('@@@@ calling determineUserRecipients - this.userRecipients : ' + this.userRecipients);
		this.addToRecipientList(this.userRecipients, flag);
	}

	public void determineContactRecipients(Boolean flag){
		this.contactRecipients = [SELECT Id, Name, Email FROM Contact WHERE Email != null];
		this.addToRecipientList(this.contactRecipients, flag);
	}

	public void determineAccountTeamMemberRecipients(Boolean flag){
	}

	public void determineAccountContactRoles(Boolean flag){
		this.accountContactRoleRecipients = [SELECT Id, Contact.Name, Contact.Id, Contact.Email, Account.Name, IsPrimary From AccountContactRole WHERE Contact.Email != null];
		this.addToRecipientList(this.accountContactRoleRecipients, flag);
	}

	public void determineOpportunityContactRoles(Boolean flag){
		this.oppContactRoleRecipeints = [SELECT Id, Contact.Name, Contact.Id, Contact.Email, Opportunity.Name, Role, IsPrimary From OpportunityContactRole WHERE Contact.Email != null];
		this.addToRecipientList(this.oppContactRoleRecipeints, flag);
	}

	private void addToRecipientList(List<sObject> records, Boolean flag){
		if(!records.isEmpty()){
			string objName = records[0].Id.getSObjectType().getDescribe().getName() + 's';
			if(emailAddresses.get(objName) == null){
				emailAddresses.put(objName, new List<EmailRecipientWrapper>());
			}
			for(SObject record : records){
				if(this.emailEditorConfig[0].Use_Single_Table_Only__c){
					if((objName.indexOf('OrgWideEmailAddress') != -1) && (selectedRecipientAddressesMap.get((String)record.get('Address')) != null)){
						List<Boolean> options = selectedRecipientAddressesMap.get((String)record.get('Address'));
						emailAddresses.get(objName).add(new EmailRecipientWrapper(record, emailAddresses.size(), options[0], options[1], options[2]));
					//} else if(selectedRecipientAddressesMap.get((String)record.get('Email')) != null){
					} else if((objName.indexOf('OrgWideEmailAddress') == -1)  && selectedRecipientAddressesMap.get((String)record.get('Email')) != null){
						List<Boolean> options = selectedRecipientAddressesMap.get((String)record.get('Email'));
						emailAddresses.get(objName).add(new EmailRecipientWrapper(record, emailAddresses.size(), options[0], options[1], options[2]));
					} else {
						emailAddresses.get(objName).add(new EmailRecipientWrapper(record, emailAddresses.size(), false, false, false));
					}
				} else {
					if((objName.indexOf('OrgWideEmailAddress') != -1) && (selectedAddressesMap.get((String)record.get('Address')) != null)){
						emailAddresses.get(objName).add(new EmailRecipientWrapper(record, true));
					//} else if(selectedAddressesMap.get((String)record.get('Email')) != null){
					} else if((objName.indexOf('OrgWideEmailAddress') == -1) &&  selectedAddressesMap.get((String)record.get('Email')) != null){
						emailAddresses.get(objName).add(new EmailRecipientWrapper(record, true));
					} else {
						emailAddresses.get(objName).add(new EmailRecipientWrapper(record, false));
					}
				}
			}
		}
	}

	public void buildSenderEmailList(Boolean flag, String searchOption){
		this.title = 'Sender Email Address';
		if(this.emailEditorConfig[0].Show_Options_On_Page__c && String.isNotBlank(searchOption)){
			if(searchOption.equals('user_only')){
				this.determineUserRecipients(flag);
			} else if(searchOption.equals('org_wide_only')){
				this.determineOrgWideEmailAddresses(flag);
			} else if(searchOption.equals('from_both')){
				this.determineUserRecipients(flag);
				this.determineOrgWideEmailAddresses(flag);
			}
		} else {
			if(this.emailEditorConfig[0].FromEmail_User_Only__c){
				this.determineUserRecipients(flag);	
			} else if(this.emailEditorConfig[0].FromEmail_OrgWide_Only__c){
				this.determineOrgWideEmailAddresses(flag);
			} else if(this.emailEditorConfig[0].FromEmail_Both_Only__c){
				this.determineUserRecipients(flag);
				this.determineOrgWideEmailAddresses(flag);
			}
		}
	}

	public void buildRecipientEmailList(Boolean flag, String searchOption){
		this.title = 'Recipient Email Address';
		if(String.isNotBlank(searchOption) && this.emailEditorConfig[0].Show_Options_On_Page__c){
			if(searchOption.equals('user_only')){
				this.determineUserRecipients(flag);
			} else if(searchOption.equals('contact_only')){
				this.determineContactRecipients(flag);
			} else if(searchOption.equals('to_both')){
				this.determineUserRecipients(flag);
				this.determineContactRecipients(flag);
			}
		} else {
			if(this.emailEditorConfig[0].RecipientEmail_Users_Only__c){
				this.determineUserRecipients(flag);	
			} else if(this.emailEditorConfig[0].RecipientEmail_Contacts_Only__c){
				this.determineAccountContactRoles(flag);
				this.determineOpportunityContactRoles(flag);
				this.determineContactRecipients(flag);
			} else if(this.emailEditorConfig[0].RecipientEmail_Both_Only__c){
				this.determineUserRecipients(flag);
				this.determineAccountContactRoles(flag);
				this.determineOpportunityContactRoles(flag);
				this.determineContactRecipients(flag);
			}
		}
	}
}