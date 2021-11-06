
import Foundation

class ServiceClient {
    // MARK: URL tasks
    class func dataTask(url: URL, completion: @escaping(Data?, String?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                completion(nil, error?.localizedDescription)
                return
            }
            completion(data, nil)
        }
        task.resume()
    }
    
    class func taskForGetRequest<ResponseType: Decodable>(url: URL, responceType: ResponseType.Type, completion: @escaping(ResponseType?, String?) -> Void) {
        dataTask(url: url) { data, error in
            guard let data = data else {
                completion(nil, error)
                return
            }
            let decoder = JSONDecoder()
            
            do {
                let responseObject = try decoder.decode(responceType, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error.localizedDescription)
                }
            }
        }
    }
    
    class func taskForPostRequest<ResponceType: Decodable, RequestType: Codable>(url: URL, responceType: ResponceType.Type, requestBody: RequestType, completion: @escaping(ResponceType?, String?) -> Void) {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let encoder = JSONEncoder()
        let requestBodyData = try! encoder.encode(requestBody)
        urlRequest.httpBody =  requestBodyData
        
        let task = URLSession.shared.dataTask(with: urlRequest) {data, responce, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error?.localizedDescription)
                }
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let responceObject = try decoder.decode(responceType, from: data)
                DispatchQueue.main.async {
                    completion(responceObject, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error.localizedDescription)
                }
            }
        }
        task.resume()
    }
    
    // MARK: Get information from monitor
    class func getMonitorStatus(completion: @escaping([MonitorGroup]?, String?)-> Void) {
        taskForGetRequest(url: Endpoints.getMonitorStatus.url, responceType: [MonitorGroup].self) { data, error in
            
            guard let data = data else {
                completion(nil, error)
                return
            }
            
            completion(data, nil)
        }
    }
    
    class func getGroupStatus(id: Int, completion: @escaping(MonitorGroup?, String?)-> Void) {
        taskForGetRequest(url: Endpoints.getGroupStatus(id: id).url, responceType: MonitorGroup.self)  { data, error in
            guard let data = data else {
                completion(nil, error)
                return
            }
            completion(data, nil)
        }
    }
    
    class func getServiceStatus(id: Int, completion: @escaping(MonitorService?, String?)-> Void) {
        taskForGetRequest(url: Endpoints.getServiceStatus(id: id).url, responceType: MonitorService.self) { data, error in
            guard let data = data else {
                completion(nil, error)
                return
            }
            completion(data, nil)
        }
    }
    
    private func handleMonitorData<dataType: Decodable>(data: dataType?, error: String?, completion:@escaping(dataType?, String?)-> Void) {
        guard let data = data else {
            completion(nil, error)
            return
        }
        completion(data, nil)
    }
    
    // MARK: CRUD operations
    class func addToMonitor<serviceObject: Codable>(serviceObject: serviceObject, url: URL, completion: @escaping(Int?, String?) -> Void) {
        taskForPostRequest(url: url, responceType: MonitorResponce.self, requestBody: serviceObject) { response, error in
            guard let response = response else {
                completion(nil, error)
                return
            }
            
            if response.success == true {
                if response.id != nil {
                    completion(response.id, nil)
                } else {
                    completion(nil, response.description)
                }
            } else {
                completion(nil, response.description)
            }
        }
    }
    
    class func updateOnMonitor<serviceObject: Codable>(serviceObject: serviceObject, url: URL, completion: @escaping(Bool, String?) -> Void) {
        taskForPostRequest(url: url, responceType: MonitorResponce.self, requestBody: serviceObject) { responce, error in
            guard let responce = responce else {
                completion(false, error)
                return
            }
            
            if responce.success == true {
                completion(true, nil)
            } else {
                completion(false, responce.description)
            }
        }
    }
    
    class func deleteOnMonitor(id: Int, url: URL, completion: @escaping(Bool, String?) -> Void) {
        taskForGetRequest(url: url, responceType: MonitorResponce.self) { responce, error in
            guard let responce = responce else {
                completion(false, error)
                return
            }
            
            if responce.success == true {
                completion(true, nil)
            } else {
                completion(false, responce.description)
            }
        }
    }
}

enum Endpoints {
    static let base = "https://bonus.1hmm.ru/MonitorWebService-0.1/rest/methods/"
    
    case getMonitorStatus
    case addGroup
    case deleteGroup(id: Int)
    case updateGroup
    case addService
    case updateService
    case deleteService(id: Int)
    case getGroupStatus(id: Int)
    case getServiceStatus(id: Int)
    
    var stringValue: String {
        switch self {
        case .getMonitorStatus: return Endpoints.base + "GetMonitorStatus"
        case .addGroup: return Endpoints.base + "AddGroup"
        case .deleteGroup(id: let id): return Endpoints.base + "DeleteServiceGroup?id=\(id)"
        case .updateGroup: return Endpoints.base + "UpdateGroup"
        case .addService: return Endpoints.base + "AddService"
        case .updateService: return Endpoints.base + "UpdateService"
        case .deleteService(id: let id): return Endpoints.base + "DeleteService?id=\(id)"
        case .getGroupStatus(id: let id): return Endpoints.base + "GetGroup?id=\(id)"
        case .getServiceStatus(id: let id): return Endpoints.base + "GetServiceStatus?id=\(id)"
        }
    }
    
    var url: URL {
        return URL(string: stringValue)!
    }
}
