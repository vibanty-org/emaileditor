public with sharing class EmailRecipientWrapper {
	public Boolean selected { get; set; }
	public SObject record { get; set; }
	public Set<String> control { get; set; }

	public Integer position { get; set; }
	public Boolean to { get; set; }
	//public Boolean additionalTo { get; set; }
	public Boolean cc { get; set; }
	public Boolean bcc { get; set; }

	public EmailRecipientWrapper(SObject record, Boolean selected){
		this.selected = selected;
		this.record = record;
	}

	/*public EmailRecipientWrapper(SObject record, Integer position, Boolean to, Boolean at, Boolean cc, Boolean bcc){*/
	public EmailRecipientWrapper(SObject record, Integer position, Boolean to, Boolean cc, Boolean bcc){
		this.to = to;
		//this.additionalTo = at;
		this.cc = cc;
		this.bcc = bcc;
		this.position = position;
		this.record = record;
	}
}