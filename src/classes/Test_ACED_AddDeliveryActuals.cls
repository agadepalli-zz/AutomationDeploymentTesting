/* Class Name  : Test_ACED_AddDeliveryActuals
* Description  : Test class for ACED_AddDeliveryActuals controller
* Created By   : Goutham
* Created Date : 01-10-2014
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date                 Modification ID        Description 
   Sandeep Dharwar          10/04/2015              Us-38307           Created Audience in Delivery records
* ---------------------------------------------------------------------------------------------------------------------------------------

*/

@isTest(SeeAllData=false)
//test class for ACED_AddDeliveryActuals controller
public class Test_ACED_AddDeliveryActuals {
    
    //test method for ACED_AddDeliveryActuals controller
    static testMethod void AddDeliveryActuals() {
        
        //Declaring the user with Digital dashboard owner Permission set
        User runAsUser = ACED_DataFactory.createUser('ACED_Digital_Dashboard_Owner');
        
        Test.startTest();
        
        System.runAs(runAsUser) {
            
            
            //Inserting a list of Activities 
            List<ACED_Activity__c> lActivities=ACED_DataFactory.createActivities(1);  
             List<ACED_Activity__c> lActivities1=ACED_DataFactory.createActivities(1);  
            //declaring a list of Deliveries
            List<ACED_Deliveries__c> lDeliveries = New List<ACED_Deliveries__c>();    
               
            //Querying for channel ID which is populated from activity trigger  
            List<ACED_Activity__c> test = [select channel__c from ACED_Activity__c where ID=:lActivities[0].ID];
            
            //System assert to verify whether channel is populated from asset via activity trigger
            system.assertNotequals(test[0].Channel__c,NULL); 
            
            
            ID i = lActivities[0].Assets__c;
            
          
            //Inserting a actual channel attribute and associatng it to channel populated on activity
            ACED_Channel_Attribute__c iChnlAttrib = New ACED_Channel_Attribute__c();
            iChnlAttrib.Attribute_Name__c='Sent';
            iChnlAttrib.Channel__c=test[0].Channel__c;
            iChnlAttrib.Actual__c=true;
            iChnlAttrib.Description__c='test';
            insert  iChnlAttrib;
            
            //Inserting a potential channel attribute and associatng it to channel populated on activity
            ACED_Channel_Attribute__c iChnlAttrib3 = New ACED_Channel_Attribute__c();
            iChnlAttrib3.Attribute_Name__c='SentPot';
            iChnlAttrib3.Channel__c=test[0].Channel__c;
            iChnlAttrib3.Potential__c=true;
            iChnlAttrib3.Description__c='test';
            insert  iChnlAttrib3;
            
            //Inserting a neither potential nor actual channel attribute and associatng it to channel populated on activity
            ACED_Channel_Attribute__c iChnlAttrib2 = New ACED_Channel_Attribute__c();
            iChnlAttrib2.Attribute_Name__c='Sent2';
            iChnlAttrib2.Channel__c=test[0].Channel__c;
            insert  iChnlAttrib2;
            
            //Inserting a delivery record and assicaiting it with activity inserted above
            ACED_Deliveries__c Del = New ACED_Deliveries__c();
            //Inserting a provider record
            List<ACED_Providers__c>  lProviders=ACED_DataFactory.createProviders(1);
            list<ACED_Audience__c> lAudiences = ACED_DataFactory.createAudience(1);
            Del.Activity__c=lActivities[0].ID;
            Del.Provider__c=lProviders[0].ID;
            Del.Audience__c=lAudiences[0].ID;
            Del.PIM_Segment__c='All';
            Del.Status__c='Started';
            Del.Start_Date__c=System.today();
            Del.End_Date__c=System.today()+1;
            Del.StandAlone_Asset__c=i;
           
            lDeliveries.add(Del);
            Insert lDeliveries;
            
               
            //Setting delivery record ID inserted above as current page parameter
            ApexPages.currentPage().getParameters().put('id',lDeliveries[0].id);
            
            //Initiating the controller
            ACED_AddDeliveryActuals TestController=new  ACED_AddDeliveryActuals();
            for(string k:TestController.wdeliveryactuals[0].mValues.keyset()){
                TestController.wdeliveryactuals[0].mValues.put(k,1);
            }
            //Calling the save method on VF page
            TestController.Save();
            //Assert the delivery record got saved successfully in the system
            system.assert([Select Id from ACED_Deliveries__c where id = : lDeliveries[0].id].size()>0);
            
            for(string k:TestController.wdeliveryactuals[0].mValues.keyset()){
                TestController.wdeliveryactuals[0].mValues.put(k,-1);
            }
            //Calling the save method on VF page
            PageReference pg = TestController.Save();
            
            //Assert the delivery record not being saved successfully in the system
            system.assertEquals(pg,null);
            
            //Calling the cancel method on VF page
            TestController.Cancel();
         
        }
        
        Test.stopTest();
        
    }
    
    
    static testMethod void AddDeliveryActuals1() {
        
        //Declaring the user with Digital dashboard owner Permission set
        User runAsUser = ACED_DataFactory.createUser('ACED_Digital_Dashboard_Owner');
        
        Test.startTest();
        
        System.runAs(runAsUser) {
            
            
            //Inserting a list of Activities 
            List<ACED_Activity__c> lActivities=ACED_DataFactory.createActivities(1);  
             List<ACED_Activity__c> lActivities1=ACED_DataFactory.createActivities(1);  
            //declaring a list of Deliveries
            List<ACED_Deliveries__c> lDeliveries = New List<ACED_Deliveries__c>();    
               
            //Querying for channel ID which is populated from activity trigger  
            List<ACED_Activity__c> test = [select channel__c from ACED_Activity__c where ID=:lActivities[0].ID];
            
            //System assert to verify whether channel is populated from asset via activity trigger
            system.assertNotequals(test[0].Channel__c,NULL); 
            
            
            ID i = lActivities[0].Assets__c;
            
          
            //Inserting a actual channel attribute and associatng it to channel populated on activity
            ACED_Channel_Attribute__c iChnlAttrib = New ACED_Channel_Attribute__c();
            iChnlAttrib.Attribute_Name__c='Sent';
            iChnlAttrib.Channel__c=test[0].Channel__c;
            iChnlAttrib.Actual__c=true;
            iChnlAttrib.Description__c='test';
            insert  iChnlAttrib;
            
            //Inserting a potential channel attribute and associatng it to channel populated on activity
            ACED_Channel_Attribute__c iChnlAttrib3 = New ACED_Channel_Attribute__c();
            iChnlAttrib3.Attribute_Name__c='SentPot';
            iChnlAttrib3.Channel__c=test[0].Channel__c;
            iChnlAttrib3.Potential__c=true;
            iChnlAttrib3.Description__c='test';
            insert  iChnlAttrib3;
            
            //Inserting a neither potential nor actual channel attribute and associatng it to channel populated on activity
            ACED_Channel_Attribute__c iChnlAttrib2 = New ACED_Channel_Attribute__c();
            iChnlAttrib2.Attribute_Name__c='Sent2';
            iChnlAttrib2.Channel__c=test[0].Channel__c;
            insert  iChnlAttrib2;
            
            //Inserting a delivery record and assicaiting it with activity inserted above
            ACED_Deliveries__c Del = New ACED_Deliveries__c();
            //Inserting a provider record
            List<ACED_Providers__c>  lProviders=ACED_DataFactory.createProviders(1);
            list<ACED_Audience__c> lAudiences = ACED_DataFactory.createAudience(1);
            Del.Activity__c=lActivities[0].ID;
            Del.Provider__c=lProviders[0].ID;
            Del.Audience__c=lAudiences[0].ID;
            Del.PIM_Segment__c='All';
            Del.Status__c='Completed';
            Del.Start_Date__c=System.today()-2;
            Del.End_Date__c=System.today()-1;
         
            Del.StandAlone_Upsert_Attribute__c='';
           
            lDeliveries.add(Del);
            Insert lDeliveries;
            
            
           
            
            
            
            
            
            //Setting delivery record ID inserted above as current page parameter
            ApexPages.currentPage().getParameters().put('id',lDeliveries[0].id);
            
            //Initiating the controller
            ACED_AddDeliveryActuals TestController=new  ACED_AddDeliveryActuals();
            for(string k:TestController.wdeliveryactuals[0].mValues.keyset()){
                TestController.wdeliveryactuals[0].mValues.put(k,1);
            }
            //Calling the save method on VF page
            TestController.Save();
            //Assert the delivery record got saved successfully in the system
            system.assert([Select Id from ACED_Deliveries__c where id = : lDeliveries[0].id].size()>0);
            System.assertEquals([Select Status__c from ACED_Deliveries__c where id = : lDeliveries[0].id].Status__c,'Completed');
            //Calling the cancel method on VF page
            TestController.Cancel();
         
        }
        
        Test.stopTest();
        
    }
    
    
    static testMethod void testNegativeAddDeliveryActuals() {
        
        //Declaring the user with Digital dashboard owner Permission set
        User runAsUser = ACED_DataFactory.createUser('ACED_Digital_Dashboard_Owner');
        List<ACED_Deliveries__c> lDeliveries = New List<ACED_Deliveries__c>();  
        Test.startTest();
        
        System.runAs(runAsUser) {
            
            
            //Inserting a list of Activities 
            List<ACED_Activity__c> lActivities=ACED_DataFactory.createActivities(1);  
             List<ACED_Activity__c> lActivities1=ACED_DataFactory.createActivities(1);  
                
               
            //Querying for channel ID which is populated from activity trigger  
            List<ACED_Activity__c> test = [select channel__c from ACED_Activity__c where ID=:lActivities[0].ID];
            
            //System assert to verify whether channel is populated from asset via activity trigger
            system.assertNotequals(test[0].Channel__c,NULL); 
            
            
            ID i = lActivities[0].Assets__c;
            
          
            //Inserting a actual channel attribute and associatng it to channel populated on activity
            ACED_Channel_Attribute__c iChnlAttrib = New ACED_Channel_Attribute__c();
            iChnlAttrib.Attribute_Name__c='Sent';
            iChnlAttrib.Channel__c=test[0].Channel__c;
            iChnlAttrib.Actual__c=true;
            iChnlAttrib.Description__c='test';
            insert  iChnlAttrib;
            
            //Inserting a potential channel attribute and associatng it to channel populated on activity
            ACED_Channel_Attribute__c iChnlAttrib3 = New ACED_Channel_Attribute__c();
            iChnlAttrib3.Attribute_Name__c='SentPot';
            iChnlAttrib3.Channel__c=test[0].Channel__c;
            iChnlAttrib3.Potential__c=true;
            iChnlAttrib3.Description__c='test';
            insert  iChnlAttrib3;
            
            //Inserting a neither potential nor actual channel attribute and associatng it to channel populated on activity
            ACED_Channel_Attribute__c iChnlAttrib2 = New ACED_Channel_Attribute__c();
            iChnlAttrib2.Attribute_Name__c='Sent2';
            iChnlAttrib2.Channel__c=test[0].Channel__c;
            insert  iChnlAttrib2;
            
            //Inserting a delivery record and assicaiting it with activity inserted above
            ACED_Deliveries__c Del = New ACED_Deliveries__c();
            //Inserting a provider record
            List<ACED_Providers__c>  lProviders=ACED_DataFactory.createProviders(1);
            list<ACED_Audience__c> lAudiences = ACED_DataFactory.createAudience(1);
            Del.Activity__c=lActivities[0].ID;
            Del.Provider__c=lProviders[0].ID;
            Del.Audience__c=lAudiences[0].ID;
            Del.PIM_Segment__c='All';
            Del.Status__c='Completed';
            Del.Start_Date__c=System.today()-2;
            Del.End_Date__c=System.today()-1;
         
            Del.StandAlone_Upsert_Attribute__c='';
           
            lDeliveries.add(Del);
            Insert lDeliveries;
            
            
            
        }
        
        
        
        Delete [SELECT Id, PermissionSetID FROM PermissionSetAssignment WHERE AssigneeId =: runAsUser.Id AND PermissionSet.Name = 'ACED_Digital_Dashboard_Owner' ];

        Permissionset ps = [SELECT Id, Label FROM PermissionSet WHERE Name = 'ACED_Reports_Only_User'];
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.PermissionSetId = ps.Id;
        psa.AssigneeId =  runAsUser.Id;
        insert psa;       
        
        System.runAs(runAsUser) { 
            
                                              
            //Setting delivery record ID inserted above as current page parameter
            ApexPages.currentPage().getParameters().put('id',lDeliveries[0].id);
            
            //Initiating the controller
            ACED_AddDeliveryActuals TestController=new  ACED_AddDeliveryActuals();
            for(string k:TestController.wdeliveryactuals[0].mValues.keyset()){
                TestController.wdeliveryactuals[0].mValues.put(k,1);
            }
            //Calling the save method on VF page
            TestController.Save();
            //Assert the delivery record got saved successfully in the system
            system.assert([Select Id from ACED_Deliveries__c where id = : lDeliveries[0].id].size()>0);
            System.assertEquals([Select Status__c from ACED_Deliveries__c where id = : lDeliveries[0].id].Status__c,'Completed');
            //Calling the cancel method on VF page
            TestController.Cancel();
         
        }
        
        Test.stopTest();
        
    }

}