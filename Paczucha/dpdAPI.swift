//
//  dpdAPI.swift
//  Paczucha
//
//  Created by Darek on 20/10/2020.
//

import Foundation
import SWXMLHash

private struct Zdarzenie: XMLIndexerDeserializable {
    let jednostkaNazwa: String
    let czas: String
    let nazwa: String
    
    static func deserialize(_ node: XMLIndexer) throws -> Zdarzenie {
        return try Zdarzenie(
            jednostkaNazwa: node["ax21:jednostka"]["ax21:nazwa"].value(),
            czas: node["ax21:czas"].value(),
            nazwa: node["ax21:nazwa"].value()
        )
    }
}

private var mutableData:NSMutableData = NSMutableData()
private var status = "???"
private var zdarzenia : [Zdarzenie]? = nil

func dpdAPI(parcelNumber: String, callback: @escaping () -> Void){



            let is_SoapMessage: String = "<soapenv:Envelope xmlns:soapenv='http://schemas.xmlsoap.org/soap/envelope/' xmlns:sled='http://sledzenie.pocztapolska.pl'> <soapenv:Header> <wsse:Security soapenv:mustUnderstand='1' xmlns:wsse='http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd'> <wsse:UsernameToken wsu:Id='UsernameToken-2' xmlns:wsu='http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd'> <wsse:Username>sledzeniepp</wsse:Username> <wsse:Password Type='http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText'>PPSA</wsse:Password> <wsse:Nonce EncodingType='http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-soap-message-security-1.0#Base64Binary'>X41PkdzntfgpowZsKegMFg==</wsse:Nonce> <wsu:Created>2011-12-08T07:59:28.656Z</wsu:Created> </wsse:UsernameToken></wsse:Security> </soapenv:Header> <soapenv:Body> <sled:sprawdzPrzesylke> <sled:numer>" + (parcelNumber) + "</sled:numer> </sled:sprawdzPrzesylke> </soapenv:Body> </soapenv:Envelope>"
    
            let is_URL: String = "https://tt.poczta-polska.pl/Sledzenie/services/Sledzenie.SledzenieHttpSoap11Endpoint/"
    
            let lobj_Request = NSMutableURLRequest(url: NSURL(string: is_URL)! as URL)
            let session = URLSession.shared
            var _: NSError?
    
            lobj_Request.httpMethod = "POST"
            lobj_Request.httpBody = is_SoapMessage.data(using: String.Encoding.utf8)
            //lobj_Request.addValue("http://sledzenie.pocztapolska.pl", forHTTPHeaderField: "Host")
            lobj_Request.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
            lobj_Request.addValue(String(is_SoapMessage.count), forHTTPHeaderField: "Content-Length")
            //lobj_Request.addValue("223", forHTTPHeaderField: "Content-Length")
            lobj_Request.addValue("urn:sprawdzPrzesylke", forHTTPHeaderField: "SOAPAction")
    
            var task = session.dataTask(with: lobj_Request as URLRequest, completionHandler: {data, response, error -> Void in
                print("Response:", response ?? "response nie mozna odczytac")

                var PpCompleteData = [[Any]]()

                print("Start poczya 2")

                let xml = SWXMLHash.parse(data!)
                status = xml["soapenv:Envelope"]["soapenv:Body"]["ns:sprawdzPrzesylkeResponse"]["ns:return"]["ax21:status"].element!.text
                let intStatus = Int(status)
                if intStatus == 0
                {
                  
                    
                    zdarzenia = try! xml["soapenv:Envelope"]["soapenv:Body"]["ns:sprawdzPrzesylkeResponse"]["ns:return"]["ax21:danePrzesylki"]["ax21:zdarzenia"]["ax21:zdarzenie"].value()
                    
                    print("wszystkie zdarzenia:", zdarzenia?.count ?? "BRAK")
                    if zdarzenia!.count > 0{
                        for zdarzenie in zdarzenia!{

                            let dateFormatter = DateFormatter()
                            dateFormatter.locale = Locale(identifier: "pl_PL")
                            dateFormatter.timeZone = TimeZone(abbreviation: "GMT+2:00")
                            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                            
                            print("Data do sformatowania jako string:", zdarzenie.czas)
                            let formattedDate = dateFormatter.date(from: zdarzenie.czas)
                            
                            PpCompleteData.append([zdarzenie.nazwa, formattedDate!, zdarzenie.jednostkaNazwa])
                            
                        }
                    }
                }
            CDHandler.updateStatuses(fetchedStatuses: PpCompleteData, parcelNumber: parcelNumber)
            callback()
                
    
                if error != nil
                {
                    print("Error: ", error)
                }
    
            })
            task.resume()
    
    
    }
    



