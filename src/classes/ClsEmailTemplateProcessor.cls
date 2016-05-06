public with sharing class ClsEmailTemplateProcessor {

	private String templateId;
	private String relatedTo;
	private EmailTemplate emailTemplate;
	private Boolean isError;
	private EmailObject emailObj;
	private String objectTargetId;

	public ClsEmailTemplateProcessor(String templateId, String relatedTo, String objectTargetId) {
		this.templateId = templateId;
		this.relatedTo = relatedTo;
		this.objectTargetId = objectTargetId;
		this.isError = false;
	}

	public ClsEmailTemplateProcessor(String templateId, String relatedTo) {
		this.templateId = templateId;
		this.relatedTo = relatedTo;
		this.isError = false;
	}

	public List<String> getEmailHtmlValue(){
		List<String> templateInfo = new List<String>();
		this.getQuoteEmailTemplate();
		system.debug('@@@@ calling this.emailObj.mailHtmlBody : ' + this.emailObj.mailHtmlBody);
		system.debug('@@@@ calling this.emailObj.mailTextBody : ' + this.emailObj.mailTextBody);
		if(!isError){
			if(this.emailObj != null && this.emailObj.mailHtmlBody !=  null && String.isNotBlank(this.emailObj.mailHtmlBody)){
				//return this.emailObj.mailHtmlBody;
				templateInfo.add(this.emailObj.mailHtmlBody);
				if(this.emailObj.mailSubject != null){
					templateInfo.add(this.emailObj.mailSubject);
				}
				return templateInfo;
			} else if(this.emailObj != null && this.emailObj.mailTextBody != null && String.isNotBlank(this.emailObj.mailTextBody)){
				//return this.emailObj.mailTextBody;
				templateInfo.add(this.emailObj.mailTextBody);
				if(this.emailObj.mailSubject != null){
					templateInfo.add(this.emailObj.mailSubject);
				}
				return templateInfo;
			} else {
				templateInfo.add('error');
				return templateInfo;
			}
		} else {
			templateInfo.add('error');
			return templateInfo;
		}
	}	

	private void getQuoteEmailTemplate(){
		try{
			emailTemplate = [SELECT id, HtmlValue FROM EmailTemplate WHERE Id =: templateId limit 1]; 
			this.renderHtmlEmail();
			this.isError = false;
		} catch(Exception e) {
			this.isError = true;
			System.debug('@@@@ calling getQuoteEmailTemplate in ClsQuoteProcessor. The following error occurred : ' +  e.getMessage());
		}
	}

	private void renderHtmlEmail(){
		system.debug('@@@@ calling renderHtmlEmail : ' + this.objectTargetId);
        Messaging.reserveSingleEmailCapacity(1);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[]{'testEmail@fake.de'};
        Contact c = [select id, Email from Contact where email <> null limit 1];
        mail.setToAddresses(toAddresses);
        mail.setUseSignature(false);
        mail.setSaveAsActivity(false);
        mail.setSenderDisplayName('None');
        //mail.setTargetObjectId(UserInfo.getUserId());
        //mail.setWhatId(this.relatedTo);
        //mail.setTargetObjectId(UserInfo.getUserId());
        if(this.objectTargetId != null){
        	if(!((Id)this.objectTargetId).getSObjectType().getDescribe().getName().equals('User')){
        		mail.setWhatId(this.relatedTo);
        	}
        	mail.setTargetObjectId((Id)this.objectTargetId);
    	} else {
    		mail.setWhatId(this.relatedTo);
    		mail.setTargetObjectId(c.Id);
    	}
        
        if(this.emailTemplate != null){
            mail.setTemplateId(this.emailTemplate.Id);
        }
        Savepoint sp = Database.setSavepoint();
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
        Database.rollback(sp);
        this.emailObj = new EmailObject(mail);
    }

    public class EmailObject{
        public String mailTextBody;
        public String mailHtmlBody;
        public String mailSubject;

        public emailObject(Messaging.SingleEmailMessage mail){
            this.mailTextBody = mail.getPlainTextBody();
            this.mailHtmlBody = mail.getHTMLBody();
            this.mailSubject = mail.getSubject();
        }

    }
}