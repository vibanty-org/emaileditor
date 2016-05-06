public with sharing class ClsEmailEditorHelper {

	//public List<SelectOption> folders { get; set; }

	public ClsEmailEditorHelper() {
		
	}

	public List<SelectOption> getFolderListOptions(){
		List<SelectOption> folders = new List<SelectOption>();
		folders.add(new SelectOption('none', '--- Select folder ---'));
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
			folders.add(new SelectOption(str, folderMap.get(str)));
		}
		return folders;
	}
}