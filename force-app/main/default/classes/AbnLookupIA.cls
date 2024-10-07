public class AbnLookupIA {
    
    @InvocableMethod(label='Lookup ABN')
    public static List<OutputData> execute(List<InputData> inputs) {

        List<String> responseKeys = new List<String>{ 'AbnStatus', 'Acn', 'AddressPostcode', 'AddressState', 'EntityName', 'EntityTypeCode', 'EntityTypeName', 'Message' };      
        
        List<OutputData> outputs = new List<OutputData>();
        for(InputData input : inputs) {
            
            String abn = input.abn.replaceAll('[^0-9]','');
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://abr.business.gov.au/json/AbnDetails.aspx?callback=callback&abn='+abn+'&guid='+input.guid);
            req.setMethod('GET');
            req.setHeader('Content-Type', 'application/json');
            req.setTimeout(30000);
            
            Http http = new Http();
            HttpResponse resp = http.send(req);
            
            String responseBody = resp.getBody();
            responseBody = responseBody.removeStart('callback(').removeEnd(')');
            System.debug(responseBody);
            
			OutputData output = new OutputData();
            try {
                output = (OutputData)JSON.deserialize(responseBody,OutputData.class);
                if(output.BusinessName.size() > 0) {
                    output.BusinessNames = String.join(output.BusinessName, '; ');
                }
            } catch(Exception e) {
                System.debug('*** Exception: '+e.getMessage());
            }
            
            System.debug(output);
            
            outputs.add(output);
            
        }
        return outputs;
        
    }
        
    public class InputData {
        @InvocableVariable public String abn;
        @InvocableVariable public String guid;
    }
    
    public class OutputData {
        @InvocableVariable public String Abn;
        @InvocableVariable public String AbnStatus;
        @InvocableVariable public String Acn;
        @InvocableVariable public String AddressPostcode;
        @InvocableVariable public String AddressState;
        @InvocableVariable public List<String> BusinessName;
        @InvocableVariable public String BusinessNames;
        @InvocableVariable public String EntityName;
        @InvocableVariable public String EntityTypeCode;
        @InvocableVariable public String EntityTypeName;
        @InvocableVariable public String Gst;
        @InvocableVariable public String Message;
    }

}