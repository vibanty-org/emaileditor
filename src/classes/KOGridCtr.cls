public with sharing class KOGridCtr {
	
	public String chosenFiscalYear{get; set;}
	public String chosenRegion {get; set;}
	public Map<String, Financial__c> mainRow { get; set; }
	public Map<String, List<Financial__c>> financials { get; set; }
	public List<FinancialRecords> financialRecords { get; set; }
	public String financialRecordsJson { get; set; }
	public List<String> headerList { get; set; }
	
	public KOGridCtr() {
		retrieveFinancials();
	}
	
	public List<SelectOption> getFiscalYear(){
	    List<SelectOption> options = new List<SelectOption>();    
	    Schema.DescribeFieldResult fieldResult = Financial__c.Fiscal_Year__c.getDescribe();
	    List<Schema.PicklistEntry> cfy = fieldResult.getPicklistValues();
	    for( Schema.PicklistEntry f : cfy){
	        options.add(new SelectOption(f.getLabel(), f.getValue()));
	    }
	    system.debug('@@@@ Inside getFiscalYear options: ' + options);
	    chosenFiscalYear = cfy[0].getValue();
	    return options;
    }
    
    public List<SelectOption> getRegion(){
	    List<SelectOption> options = new List<SelectOption>();    
	    Schema.DescribeFieldResult fieldResult = Financial__c.Region__c.getDescribe();
	    List<Schema.PicklistEntry> cr = fieldResult.getPicklistValues();
	    for( Schema.PicklistEntry f : cr){
	        options.add(new SelectOption(f.getLabel(), f.getValue()));
	    }
	    system.debug('@@@@ Inside getRegion options: ' + options);
	    chosenRegion = cr[0].getValue();
	    return options;
    }
    
    private List<String> retrieveBusinessUnit(){
    	List<String> bu = new List<String>();
    	Schema.Describefieldresult fieldResult = Financial__c.BU__c.getDescribe();
    	List<Schema.Picklistentry> buList = fieldResult.getPicklistValues();
    	for(Schema.Picklistentry f : buList){
    		bu.add(f.getValue());
    	}
    	return bu;
    }
    
    public String retreiveFinancials(){
    	List<Financial__c> financials = [SELECT id, Region__c, Account__r.Name, Fiscal_Year__c, ForcastLastYear__c, X_Plan__c, Y_Plan__c, Z_Plan__c, Total_Plan__c FROM Financial__c];
    	system.debug('@@@@ Inside queryFinancials financial - financials : ' + financials);
    	return Json.serialize(financials);
    }
    
    public void retrieveFinancials(){
    	List<Financial__c> financialList = [SELECT Id, Account__c, Business_Unit__c, BU__c, Region__c, Total_Plan__c, X_Plan__c, Y_Plan__c, Z_Plan__c, Fiscal_Year__c, ForcastLastYear__c, Product__c, Growth__c FROM Financial__c ORDER BY Business_Unit__c];
    	buildBUMap(financialList);	
    }
    
    public void buildBUMap(List <Financial__c> financials){
    	financialRecords = new List<FinancialRecords>();
    	List<String> businessUnits = retrieveBusinessUnit();	
    	for(String bu : businessUnits) {
    		String buToLowerCase = bu.toLowerCase();
    		List<Financial__c> cdpFinancialsForSingleBU = new List<Financial__c>();
    		for(Financial__c financial : financials){
    			if(financial.BU__c != null && financial.BU__c.equals(bu)){
    				cdpFinancialsForSingleBU.add(financial);
    			}
    		}

	    	financialRecords.add(new FinancialRecords(aggregateProductCount(cdpFinancialsForSingleBU, bu), true, buToLowerCase));
	    	for(Financial__c rec : cdpFinancialsForSingleBU){
	    		financialRecords.add(new FinancialRecords(rec, false, buToLowerCase));
	    	}
    	}
    	financialRecordsJson = Json.serialize(financialRecords);
    	system.debug('@@@@ Inside buildBUMap - financialRecords: ' + financialRecords);
    }
    
    public Financial__c aggregateProductCount(List<Financial__c> financials, String bu){
    	Decimal productCount = 0;
    	Decimal xplan = 0;
    	for(Financial__c financial : financials){
    		productCount += financial.ForcastLastYear__c;
    		xplan += financial.X_Plan__c;
    	}
    	return new Financial__c(ForcastLastYear__c = productCount, Business_Unit__c = bu, X_Plan__c = xplan);
    }
    
    public PageReference saveFinancials(){
    	return null;
    }
    
    public PageReference updateFinancials(){
    	List<Financial__c> unwrappedFinancials = new List<Financial__c>();
    	system.debug('@@@@ Inside updateFinancials: ' + financialRecords);
    	unwrappedFinancials = unWrapFinancials(financialRecords);
    	
    	Map<String, String> pageParams = Apexpages.currentPage().getParameters();
    	system.debug('@@@@ Inside updateFinancials - pageParams: ' + pageParams);
    	
    	for(Financial__c ff : unwrappedFinancials){
    		for(String ss : pageParams.keySet()){
    			if(ff.Id == ss){
    				system.debug('@@@@ value: ' + ss + '__' + pageParams.get(ss));
    			}
    		}
    	}
    	
    	
    	buildBUMap(unwrappedFinancials);
    	return null;
    }
    
    public List<Financial__c> unWrapFinancials(List<FinancialRecords> financialRecords){
    	system.debug('@@@@ Inside unWrapFinancials: financialRecords --- ' + financialRecords);
    	List<Financial__c> unwrappedFinancials = new List<Financial__c>();
    	for(FinancialRecords  record : financialRecords){
    		if(!record.isBu){
    			unwrappedFinancials.add(record.singleRecord);
    		}
    		system.debug('======================================= Begin ==================================================');
    		//system.debug('@@@@ Inside unWrapFinancials record.isBu -- ' + record.isBu + 'BU: -- ' + record.singleRecord.Business_Unit__c);
    		system.debug(' FINANCIAL RECORD: ' + record);
    		system.debug(' IS BU: ' + record.isBu);
    		system.debug('======================================= END ==================================================');
    	}
    	system.debug('@@@@ Inside unWrapFinancials: unwrappedFinancials-- ' + unwrappedFinancials);
    	return unwrappedFinancials;
    }
    
    public class FinancialRecords{
    	public Boolean isBu { get;  set; }
    	public String className { get;  set; }
    	public String clickListener { get; set;}
    	public Financial__c singleRecord { get; set; }
    		
    	public FinancialRecords(Financial__c financial, Boolean bu, String cn){
    		singleRecord = financial;
    		isBu = bu;
    		className = cn;
    		if(bu){
    			clickListener = 'bu_collapse(\'this\', \'' + cn + '_child\')';
    			className = cn;
    		} else {
    			className = cn + '_child';
    		}
    	}
    }
    
     public class FinancialRecord{
    	public Boolean isBu { get;  set; }
    	public String className { get;  set; }
    	public String clickListener { get; set;}
    	public Financial__c singleRecord { get; set; }
    		
    	public FinancialRecord(Financial__c financial, Boolean bu, String cn, String el){
    		singleRecord = financial;
    		isBu = bu;
    		className = cn;
    		clickListener = el;
    	}
    }
}