//
//  ppAPI.swift
//  Paczucha
//
//  Created by Darek on 20/10/2020.
//

import Foundation
import SWXMLHash

private struct PocztaPolskaStatus: XMLIndexerDeserializable {
    let agency: String
    let date: String
    let status: String
    
    static func deserialize(_ node: XMLIndexer) throws -> PocztaPolskaStatus {
        return try PocztaPolskaStatus(
            agency: node["ax21:jednostka"]["ax21:nazwa"].value(),
            date: node["ax21:czas"].value(),
            status: node["ax21:nazwa"].value()
        )
    }
}

private var mutableData:NSMutableData = NSMutableData()
private var statuses : [PocztaPolskaStatus]? = nil

func PocztaPolskaAPI(parcelNumber: String, callback: @escaping () -> Void){

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
    
    let task = session.dataTask(with: lobj_Request as URLRequest, completionHandler: {data, response, error -> Void in
                print("Response:", response ?? "response nie mozna odczytac")

                var PpCompleteData = [Status]()

                let xml = SWXMLHash.parse(data!)
                let status = xml["soapenv:Envelope"]["soapenv:Body"]["ns:sprawdzPrzesylkeResponse"]["ns:return"]["ax21:status"].element!.text
                let intStatus = Int(status)
                if intStatus == 0 {
                    statuses = try! xml["soapenv:Envelope"]["soapenv:Body"]["ns:sprawdzPrzesylkeResponse"]["ns:return"]["ax21:danePrzesylki"]["ax21:zdarzenia"]["ax21:zdarzenie"].value()
                    
                    if statuses!.count > 0{
                        for zdarzenie in statuses!{

                            let dateFormatter = DateFormatter()
                            dateFormatter.locale = Locale(identifier: "pl_PL")
                            dateFormatter.timeZone = TimeZone(abbreviation: "GMT+2:00")
                            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                            
                            print("Data for format as string:", zdarzenie.date)
                            let formattedDate = dateFormatter.date(from: zdarzenie.date)
                            guard let formattedDate = formattedDate else {
                                return
                            }
                            
                            let status = Status(status: zdarzenie.status, date: formattedDate, agency: zdarzenie.agency, statusDetails: nil)

                            PpCompleteData.append(status)
                            
                        }
                    }
                }
            CDHandler().updateStatuses(downloadedStatuses: PpCompleteData, parcelNumber: parcelNumber)
            callback()
                
            if error != nil {
                print("Error: ", error!)
            }
        })
        task.resume()
}
    



