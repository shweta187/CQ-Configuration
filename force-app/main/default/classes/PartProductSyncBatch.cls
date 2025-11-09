public with sharing class PartProductSyncBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    
     /* @name start
     * @description This method is used to fetch the active part records that don't have product
     * @return Database.QueryLocator List of parts to be updated
       since 11092025
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query;
        query = 'SELECT Id, Name, SQX_Part_Number__c, SQX_Product__c FROM SQX_Part__c WHERE SQX_Product__c = null AND SQX_Active__c = true';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<SQX_Part__c> scope) {
        if (scope == null || scope.isEmpty()) return;

        Set<String> partNames = new Set<String>();
        Set<String> partNumbers = new Set<String>();

        for (SQX_Part__c p : scope) {
            if (p.Name != null) partNames.add(p.Name);
            if (p.SQX_Part_Number__c != null) partNumbers.add(p.SQX_Part_Number__c);
        }

        List<Product2> existingProduct = new List<Product2>();

        if (!partNames.isEmpty() || !partNumbers.isEmpty()) {
            String nameCondition = (partNames.isEmpty()) ? '' : 'Name IN :partNames';
            String codeCondition = (partNumbers.isEmpty()) ? '' : 'ProductCode IN :partNumbers';
            // Build dynamic where condition for query
            String whereClause;
            if (!String.isBlank(nameCondition) && !String.isBlank(codeCondition)) {
                whereClause = nameCondition + ' OR ' + codeCondition;
            } else if (!String.isBlank(codeCondition)) {
                whereClause = codeCondition;
            } else {
                whereClause = nameCondition;
            }
            existingProduct = Database.query('SELECT Id, Name, ProductCode FROM Product2 WHERE ' + whereClause);
        }

        // get the existing products based on ProductCode or Name
        Map<String, Product2> prodByName = new Map<String, Product2>();
        Map<String, Product2> prodByCode = new Map<String, Product2>();

        Map<String, Product2> prodByNameCode = new Map<String, Product2>();

        for (Product2 p : existingProduct) {
            // if (p.Name != null && !prodByName.containsKey(p.Name)) prodByName.put(p.Name, p);
            // if (p.ProductCode != null) prodByCode.put(p.ProductCode, p);
            String comp = (p.Name == null ? '' : p.Name.trim()) + '|' + (p.ProductCode == null ? '' : p.ProductCode.trim());
            prodByNameCode.put(comp, p);
        }

        // Products to create
        List<Product2> productsToCreate = new List<Product2>();

        for(SQX_Part__c part : scope){
            string key = (part.Name == null ? '' : part.Name.trim()) + '|' + (part.SQX_Part_Number__c == null ? '' : part.SQX_Part_Number__c.trim());
            if (!prodByNameCode.containsKey(key)) {
                Product2 p = new Product2();
                p.Name = part.Name;
                p.ProductCode = part.SQX_Part_Number__c;
                p.IsActive = true;
                productsToCreate.add(p);
            }
        }

        List<SQX_Part__c> partsToUpdate = new List<SQX_Part__c>();

        // Null check & Insert new products
        if (!productsToCreate.isEmpty()) {
            insert productsToCreate;

            Set<String> setOfPName = new Set<String>();
            Set<String> setOfPCode = new Set<String>();
            for (Product2 p : productsToCreate) {
                setOfPName.add(p.Name);
                setOfPCode.add(p.ProductCode);
            }
            List<Product2> listOfProducts = [SELECT Id, Name, ProductCode, IsActive FROM Product2 WHERE Name IN :setOfPName AND ProductCode IN :setOfPCode];
            for (Product2 p : listOfProducts) {
                String comp = (p.Name == null ? '' : p.Name.trim()) + '|' + (p.ProductCode == null ? '' : p.ProductCode.trim());
                prodByNameCode.put(comp, p);
            }

            for(SQX_Part__c part : scope){
                string key = (part.Name == null ? '' : part.Name.trim()) + '|' + (part.SQX_Part_Number__c == null ? '' : part.SQX_Part_Number__c.trim());
                if (prodByNameCode.containsKey(key)) {
                    part.SQX_Product__c = prodByNameCode.get(key).Id;
                    partsToUpdate.add(part);
                }
            }
        }
        if (!partsToUpdate.isEmpty()) {
            update partsToUpdate;
        }
    }

    public void finish(Database.BatchableContext bc) {
       
    }
}