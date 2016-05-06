public with sharing class CtrCustomLookup extends ClsEmailEditorBase{
	public String typ { get; set; }
	public String searchOption { get; set; }


	public CtrCustomLookup() {
		this.typ = ApexPages.currentPage().getParameters().get('typ');
		this.searchOption = ApexPages.currentPage().getParameters().get('option');
		this.selectedAddresses = ApexPages.currentPage().getParameters().get('selectedAddresses');
		this.selectedToAddresses = ApexPages.currentPage().getParameters().get('toAddr');
		this.selectedCcAddresses = ApexPages.currentPage().getParameters().get('ccAddr');
		this.selectedBccAddresses = ApexPages.currentPage().getParameters().get('bccAddr');
		this.buildRecipientList();
	}

	public void buildRecipientList(){
		if(this.typ.equals('from')){
			if(String.isNotBlank(this.selectedAddresses)){
				this.buildEmailForSelectedAddresses();	
			}	
			this.buildSenderEmailList(true, this.searchOption);
		} else if(this.typ.equals('to') || this.typ.equals('cc') || this.typ.equals('bcc') || this.typ.equals('all')){
			if(this.typ.equals('all') && (String.isNotBlank(this.selectedToAddresses) || String.isNotBlank(this.selectedCcAddresses) || String.isNotBlank(this.selectedBccAddresses))){
				this.buildEmailForSelectedRecipientAddresses();
			} else if(String.isNotBlank(this.selectedAddresses)){
				this.buildEmailForSelectedAddresses();
			}
			this.buildRecipientEmailList(true, this.searchOption);
		} 
	}
}