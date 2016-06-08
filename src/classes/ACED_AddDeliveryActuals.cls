/* Class Name  : ACED_AddDeliveryActuals
* Description  : Control Extension class on various Asset Actual and Delivery Actual Visualforce Pages
* 
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date             Modification ID            Description 
Sandeep Dharwar         10/03/2015          US-37755                     To restrict eInteraction for completed Deliveries
Sandeep Dharwar        12/16/2015           US-40496                     To undo the changes of US-37755
Subhranshu Mohanty     26/05/2016           DEF-006791                   Allow to update the delivery actuals value to 0
* ---------------------------------------------------------------------------------------------------------------------------------------

*/
public with sharing class ACED_AddDeliveryActuals {
    
    Public List<ACED_Delivery_Actuals__c> lDeliveryActuals{get;set;}
    Public ACED_Deliveries__c oDelivery {get;set;}
    Public List<String> sChannelAttributes {get;private set;}
    Public List<wDeliveryActualLineItems > wDeliveryActuals{get;set;}
    Public Map<String,String> mHelpText{get;private set;}
    public Map<String, Boolean> mHelpTextBool {get; set;}
    Map<String,Map<String,Decimal>> mDeliveryValues = new Map<String,Map<String,Decimal>>();
    Boolean bIsAutomaticallyCreated;
    public Boolean bSaveRendered {get;set;}
    public Boolean bSectionRendered {get;set;}
    string sPrimaryChannel;
    Public  Boolean Chattribute;
    
    Public Map<String,Decimal> mValues{get;private set;}
    Date delDate;
    Integer delYear;
    String YearStr;
    
    Public ACED_AddDeliveryActuals(){
        delDate = date.today();
        delYear = delDate.Year(); 
        YearStr = string.valueof(delYear);
        bSaveRendered= true;
        bSectionRendered=true;
        Chattribute=false;
        try{
            mHelpText = new Map<String,String>();
            
            mHelpTextBool = new Map<String, Boolean>();
            lDeliveryActuals = new List<ACED_Delivery_Actuals__c>();
            wDeliveryActuals = new List<wDeliveryActualLineItems >();
            
            wDeliveryActuals = new List<wDeliveryActualLineItems >();
            
            String oDeliveryId  = ApexPages.currentPage().getParameters().get('id');
            String sCurrentObjectType = ((Id)oDeliveryId).getSObjectType().getDescribe().getName();
            string query = 'Select ';
            for(Schema.FieldSetMember f :SObjectType.ACED_Deliveries__c.FieldSets.Delivery_Header.getFields()) {
                if(f.getFieldPath()!='Activity__r.Channel__c')
                    query += f.getFieldPath() + ', ';
            }
            for(Schema.FieldSetMember f :SObjectType.ACED_Asset__c.FieldSets.ACED_Asset.getFields()) {
                if(f.getFieldPath()!='Channel__c')
                    query += 'StandAlone_Asset__r.'+f.getFieldPath() + ', ';
            } 
            
            if(sCurrentObjectType == 'ACED_Deliveries__c'){
                Query = Query +'Id,StandAlone_Asset__c,Activity__r.Channel__c,StandAlone_Asset__r.Channel__c from ACED_Deliveries__c WHERE Id = : oDeliveryId';
            }
            else if(sCurrentObjectType == 'ACED_Asset__c'){
                Query = Query +'Id,StandAlone_Asset__c,StandAlone_Asset__r.Channel__c,Activity__r.Program__r.Year__c from ACED_Deliveries__c WHERE StandAlone_Asset__c = : oDeliveryId AND Activity__r.Program__r.Year__c=:YearStr';
            }   
            oDelivery = Database.query(query);
            
            
            //US-40496
            /*
            //US-37755
            if(sCurrentObjectType == 'ACED_Deliveries__c'){
                ACED_Deliveries__c oDelComplete = [select Status__c,StandAlone_Upsert_Attribute__c,StandAlone_Asset__c from ACED_Deliveries__c WHERE Id = : oDeliveryId ];
                
                if(oDelComplete.Status__c == 'Completed' ){
                    IF( oDelivery.StandAlone_Asset__c==null && String.isBlank(oDelComplete.StandAlone_Upsert_Attribute__c)  )
                    {
                        bSaveRendered=false;
                        bSectionRendered=false;
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You cannot add any more eInterations to this delivery as delivery status is completed'));
                        
                    }
                } 
            }
            
            */
            String sChannelId;
            If(oDelivery.StandAlone_Asset__c!=null)
                sChannelId = oDelivery.StandAlone_Asset__r.Channel__c;
            else
                sChannelId = oDelivery.Activity__r.Channel__c;
            
            sChannelAttributes = new List<String>();
            
            for(ACED_Channel_Attribute__c  cattr : [select id,Attribute_Name__c,Description__c,Channel__c,Actual__c  from ACED_Channel_Attribute__c  where Channel__c = : sChannelId  and Potential__c =false order by Actual__c Desc ]){
                sChannelAttributes.add(cattr.Attribute_Name__c);
                if(cattr.Description__c!=null){
                    mHelpText.put(cattr.Attribute_Name__c,cattr.Description__c);
                    mHelpTextBool.put(cattr.Attribute_Name__c, true);
                } else{ 
                    mHelpText.put(cattr.Attribute_Name__c,''); 
                    mHelpTextBool.put(cattr.Attribute_Name__c, false);
                }
                if(cattr.Actual__c)
                    sPrimaryChannel = cattr.Attribute_Name__c;
            }
            
            for(ACED_Delivery_Actual_Line__c dl  : [select id,Delivery_Actuals__r.month__c,Attribute__c,Value__c from ACED_Delivery_Actual_Line__c where Delivery_Actuals__r.delivery__c = :ApexPages.currentPage().getParameters().get('id') or Delivery_Actuals__r.delivery__r.StandAlone_Asset__c = :ApexPages.currentPage().getParameters().get('id')]){
                if(mDeliveryValues.containskey(dl.Delivery_Actuals__r.month__c)){
                    mDeliveryValues.get(dl.Delivery_Actuals__r.month__c).put(dl.Attribute__c,dl.Value__c);
                }
                else{
                    mDeliveryValues.put(dl.Delivery_Actuals__r.month__c,new map<String,Decimal>{dl.Attribute__c => dl.Value__c});
                }
                
            }
            
            Map<Decimal,String> monthsList = new Map<Decimal,String>{1=>'January',2=>'February',3=>'March',4=>'April',5=>'May',6=>'June',7=>'July',8=>'August',9=>'September',10=>'October',11=>'November',12=>'December'};
                
                for(integer j=oDelivery.start_date__c.month(); j<=oDelivery.end_date__c.month();j++)
            {
                Map<String,Decimal> mValues = new Map<String,Decimal>();
                string sMonth = monthsList.get(j);
                system.debug('sMonth: '+sMonth);
                
                for(string st : sChannelAttributes)
                {
                    if(mDeliveryValues.containskey(sMonth) && mDeliveryValues.get(sMonth).containskey(st))
                    {
                        mValues.put(st,mDeliveryValues.get(sMonth).get(st));
                    }
                    else
                        mValues.put(st,0);      
                }           
                
                wDeliveryActualLineItems stest =  new wDeliveryActualLineItems(sMonth,mValues);
                wDeliveryActuals.add(stest);
                
            }
            
        }catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.ACED_DeliveryNotEligible));
            System.debug('*exception '+e);
        }          
    }
    
    
    
    Public Pagereference cancel(){
        Pagereference p;
        if(oDelivery.StandAlone_Asset__c!=null)
            p = new Pagereference('/'+oDelivery.StandAlone_Asset__c);
        else
            p = new Pagereference('/'+oDelivery.id);
        return p;
    }
    
    Public pagereference save(){
        List<ACED_Delivery_Actuals__c> lDeliveryActuals = new List<ACED_Delivery_Actuals__c>();
        List<ACED_Delivery_Actual_Line__c> lDeliveryActualslines = new List<ACED_Delivery_Actual_Line__c>();
        Chattribute=false;
        for(wDeliveryActualLineItems DAL : wDeliveryActuals){
            ACED_Delivery_Actuals__c sDeliveryActuals = new ACED_Delivery_Actuals__c();
            
            for(string st : DAL.mValues.keyset()){
                    if(DAL.mValues.get(st)<0)
                     Chattribute=true;
                    
            }
            If(DAL.mValues.get(sPrimaryChannel)>0 || (mDeliveryValues.get(DAL.sDeliveryMonth) != null && mDeliveryValues.get(DAL.sDeliveryMonth).get(sPrimaryChannel) != null && DAL.mValues.get(sPrimaryChannel) ==0)){
                
            if (Schema.sObjectType.ACED_Delivery_Actuals__c.fields.Delivery_Attribute_Upsert__c.isCreateable() && Schema.sObjectType.ACED_Delivery_Actuals__c.fields.Month__c.isCreateable() &&
                Schema.sObjectType.ACED_Delivery_Actuals__c.fields.Delivery__c.isCreateable() && Schema.sObjectType.ACED_Delivery_Actuals__c.fields.value__c.isCreateable()
                )
                sDeliveryActuals.Delivery__c = oDelivery.Id;
                sDeliveryActuals.Delivery_Attribute_Upsert__c = oDelivery.Id+'-'+DAL.sDeliveryMonth+'-'+sPrimaryChannel;
                sDeliveryActuals.Month__c = DAL.sDeliveryMonth;
                sDeliveryActuals.value__c = DAL.mValues.get(sPrimaryChannel);
                lDeliveryActuals.add(sDeliveryActuals);      
                
                for(string st : DAL.mValues.keyset()){
                    if(DAL.mValues.get(st)>0 || (mDeliveryValues.get(DAL.sDeliveryMonth) != null && mDeliveryValues.get(DAL.sDeliveryMonth).get(st) != null && DAL.mValues.get(st) == 0)){
                        ACED_Delivery_Actual_Line__c oDeliveryActual = new ACED_Delivery_Actual_Line__c();
                   
                    if (Schema.sObjectType.ACED_Delivery_Actual_Line__c.fields.Attribute__c.isCreateable() && Schema.sObjectType.ACED_Delivery_Actual_Line__c.fields.value__c.isCreateable() &&
                   Schema.sObjectType.ACED_Delivery_Actual_Line__c.fields.Delivery_Attribute_Upsert__c.isCreateable() 
                   )
               
                        oDeliveryActual.Attribute__c = st;
                        oDeliveryActual.value__c = DAL.mValues.get(st); 
                        oDeliveryActual.Delivery_Attribute_Upsert__c = oDelivery.Id+'-'+DAL.sDeliveryMonth+'-'+st;
                        ACED_Delivery_Actuals__c a = new ACED_Delivery_Actuals__c();
                        if(Schema.sObjectType.ACED_Delivery_Actuals__c.fields.Delivery_Attribute_Upsert__c.isCreateable())
                        a.Delivery_Attribute_Upsert__c = oDelivery.Id+'-'+DAL.sDeliveryMonth+'-'+sPrimaryChannel;
                        if(Schema.sObjectType.ACED_Delivery_Actual_Line__c.fields.Delivery_Actuals__c.isCreateable()) 
                        oDeliveryActual.Delivery_Actuals__r = a;
                        lDeliveryActualslines.add(oDeliveryActual);
                    }else if(DAL.mValues.get(st) < 0){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Value cannot be in negative'));
                        return null;
                    }
                }
            }else if(DAL.mValues.get(sPrimaryChannel) < 0 || Chattribute)
                
                {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Value cannot be in negative'));
                return null;
               }    
            
                   
          }
        
        try{
            if (!ACED_Delivery_Actuals__c.sObjectType.getDescribe().isCreateable() || !ACED_Delivery_Actuals__c.sObjectType.getDescribe().isUpdateable()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,system.Label.ACED_Insufficient_Access));}
             else{
             
             if (Schema.sObjectType.ACED_Delivery_Actuals__c.fields.Delivery_Attribute_Upsert__c.isCreateable())
                 upsert lDeliveryActuals Delivery_Attribute_Upsert__c;
            
            }
            
            if (!ACED_Delivery_Actual_Line__c.sObjectType.getDescribe().isCreateable() || !ACED_Delivery_Actual_Line__c.sObjectType.getDescribe().isUpdateable()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,system.Label.ACED_Insufficient_Access));}
             else{
             
             if (Schema.sObjectType.ACED_Delivery_Actual_Line__c.fields.Delivery_Attribute_Upsert__c.isCreateable())
                 upsert lDeliveryActualslines Delivery_Attribute_Upsert__c;
            
            }
            
            Pagereference p;
            if(oDelivery.StandAlone_Asset__c!=null)
                p = new Pagereference('/'+oDelivery.StandAlone_Asset__c);
            else
                p = new Pagereference('/'+oDelivery.id);
            return p;
            
        } catch(System.Exception e) {
            ApexPages.addMessages(e);
            return null;
        }
    }
    
    Public class wDeliveryActualLineItems{
        Public string sDeliveryMonth {get;set;}
        Public Map<string,Decimal> mValues {get;set;}
        
        Public wDeliveryActualLineItems(string sDeliveryMonth, Map<string,Decimal> mValues){
            this.sDeliveryMonth = sDeliveryMonth;
            this.mValues = mValues;
        }
    }
    
}