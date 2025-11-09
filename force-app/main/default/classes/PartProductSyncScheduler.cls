global class PartProductSyncScheduler implements Schedulable{
    global void execute(SchedulableContext sc) {
        List<String> permissionSetName = new List<String>(); 

        List<PermissionSetAssignment> listPermissionSet = [SELECT Id, PermissionSetId, PermissionSet.Name, PermissionSet.ProfileId, PermissionSet.Profile.Name
                                                            FROM PermissionSetAssignment WHERE AssigneeId =:UserInfo.getUserId() 
                                                            AND PermissionSet.Profile.Name = 'System Administrator' 
                                                            AND PermissionSet.Name = 'CQ_Product_Admin' LIMIT 100]; 
               
        if(permissionSetName.size()> 0){
            Database.executeBatch(new PartProductSyncBatch(), 200);
        }
       
    }

    // String cron = '0 0 6 * * ?'; 
    // System.schedule('Daily Sync', cron, new PartProductSyncScheduler());
}
