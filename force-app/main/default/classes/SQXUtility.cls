public with sharing class SQXUtility {

    /** Description Checks whether the running user has FLS access for the given fields on the specified object, based on the intended DML operation.
     * @param objectApiName          API name of the Salesforce object (e.g., 'Product', 'SQX_Part__c')
     * @param fieldsCsv              Comma-separated list of field API names (e.g., 'Name)
     * @param operationType          Type of access to validate: 'Create', 'Update', 'Query', or 'Upsert'
     * @return Boolean               TRUE if ALL fields pass FLS checks; FALSE if any fail.
     */
  /*  public static Boolean checkFieldAccess(String objectApiName, String fieldsCsv, String operationType) {
        Boolean hasAccess = true;
        try {
            SObjectType objectType = Schema.getGlobalDescribe().get(objectApiName);
            if (objectType == null) {
                return false; // object does not exist
            }

            Map<String, SObjectField> fieldMap = objectType.getDescribe().fields.getMap();
            for (String fieldName : fieldsCsv.split(',')) {
                fieldName = fieldName.trim();
                if (!fieldMap.containsKey(fieldName)) {
                    hasAccess = false; // field does not exist
                    continue;
                }
                Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();

                // Determine required permission based on operation
                if (operationType.equalsIgnoreCase('Create')) {
                    if (!fieldDescribe.isCreateable()) hasAccess = false;
                } 
                else if (operationType.equalsIgnoreCase('Update')) {
                    if (!fieldDescribe.isUpdateable()) hasAccess = false;
                } 
                else if (operationType.equalsIgnoreCase('Query')) {
                    if (!fieldDescribe.isAccessible()) hasAccess = false;
                }
            }
        }
        catch (Exception ex) {
            hasAccess = false; // Fail-safe return
        }

        return hasAccess;
    }*/
}
