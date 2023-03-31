//
//  ViewController.swift
//  sqlite
//
//  Created by Mac on 2023/03/27.
//

import UIKit
//데이터 모델
struct MyModel: Codable{
    var id: Int
    var myName: String
    var myAge: Int?
}
class DBHelper{
    static let shared = DBHelper()
    
    var db: OpaquePointer? //sqlite 연결 정보를 담을 객체
    let databaseName = "db.sqlite"
    
    init(){
        self.db = createDB()
    }
    deinit{
        //소멸될때 db연결 종료
        sqlite3_close(db)
    }
    
    private func createDB() -> OpaquePointer? {
        var db: OpaquePointer? = nil
        
        //sqlite3 라이브러리에 정의된 함수들은 정상적으로 실행되었을 때 공통적으로 sqlite_ok상수를 반환한다
        do{
            //db파일의 경로를 읽어오기
            // 앱 내 문서 디렉터리 경로에서 sqlite db 파일을 찾고 url 객체로 생성 (파일 매니저 객체를 이용) -> url객체에 databaseName 파일 경로를 추가한 sqlite3 데이터베이스 경로를 만든다
            let dbPath: String = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appending(path: databaseName).path
            //db를 연결하여 db객체가 생성
            if sqlite3_open(dbPath, &db) == SQLITE_OK{ //db가 연결되었다면
                print("Successfully created DB.Path:\(dbPath)")
                return db
            }
        }catch{
            print("Error while creating Database-\(error.localizedDescription)")
        }
        return nil
    }
    
    
    func createTable(){
        //autoincrement -> 레코드가 생성될 때마다 자동으로 하나씩 올려주는 값 (반드시 integer)
        let query = """
        CREATE TABlE IF NOT EXISTS myTable(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        my_name TEXT NOT NULL,
        my_age INT
        );
        """
        var stmt: OpaquePointer? = nil //컴파일된 sql을 담을 객체
        //sql 구문을 전달할 준비, 컴파일된 sql 구문 객체가 생성(stmt)
        //세번째 인자는 nByte -> 음수면 \0 문자가 나올 때까지 읽는다는 의미 / 양수면 그 바이트 수만큼 읽는다는 의미
        
        /*
         sqlite3 *db: 데이터베이스 핸들, sqlite3_open()을 통해 획득한 것을 쓴다
         zSql: 쿼리 문자열
         nByte: 쿼리 문자열의 길이, -1을 넣으면 자동으로 계산
         ppStmt: 컴파일된 쿼리, 즉 스테이트먼트에 대한 포인터
         pzTail: 사용하지 않는 파라미터
         */
        if sqlite3_prepare_v2(self.db, query, -1, &stmt, nil) == SQLITE_OK { //sql 컴파일이 잘 끝났다면
            //컴파일된 sql 구문 객체를 db에 전달
            if sqlite3_step(stmt) == SQLITE_DONE{
                print("Creating table has been succesfully done.db:\(String(describing: self.db))")
            }else{
                let errorMessage = String(cString: sqlite3_errmsg(db))
                print("sqlite3_step failure while creating table: \(errorMessage)")
            }
        }else{
            let errorMessage = String(cString: sqlite3_errmsg(self.db))
            print("sqlite3_prepare failure while creating table: \(errorMessage)")
        }
        //컴파일된 sql 구문 객체를 삭제
        sqlite3_finalize(stmt)
    }
    //*주의: 객체 해제를 하는 위치에 따라서 성공적으로 실행되었을 경우에만 객체 해제를 하게되고 실패했을 때는 제대로 해제되지 않는 경우가 발생할 수 있음
    
    func insertData(name: String, age: Int){
        //id는 AutoIncrement속성을 갖고 있으니 빼줌
        let insertQuery = "insert into myTable (id, my_name, my_age) values (?,?,?);"
        var stmt: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(self.db, insertQuery, -1, &stmt, nil) == SQLITE_OK{
            sqlite3_bind_text(stmt, 2, name, -1, nil)
            sqlite3_bind_int(stmt, 3, Int32(age))
            
            
        }else{
            print("sqlite binding failure")
        }
        if sqlite3_step(stmt) == SQLITE_DONE{
            print("sqlite insertion success")
        }else{
            print("sqlite step failure")
        }
        
    }
    
    func readData() -> [MyModel]{
        let query: String = "select * from myTable;"
        var stmt: OpaquePointer? = nil
        var result: [MyModel] = []
        
        if sqlite3_prepare_v2(self.db, query, -1, &stmt, nil) != SQLITE_OK {
            let errorMessage = String(cString: sqlite3_errmsg(db)!)
            print("error while prepare: \(errorMessage)")
            return result
        }
        while sqlite3_step(stmt) == SQLITE_ROW {
            let id = sqlite3_column_int(stmt, 0) // 결과의 0번째 테이블 값
            let name = String(cString: sqlite3_column_text(stmt, 1))//결과의 1번째 테이블 값
            let age = sqlite3_column_int(stmt, 2) //결과의 2번째 테이블 값
            
            result.append(MyModel(id: Int(id), myName: String(name), myAge: Int(age)))
        }
        sqlite3_finalize(stmt)
        
        return result
    }
    //오류메세지 출력하는 함수
    private func onSQLErrorPrintErrorMessage(_ db: OpaquePointer?){
        let errorMessage = String(cString: sqlite3_errmsg(db))
        print("Error preparing update: \(errorMessage)")
        return
    }
    
    func updateData(id: Int, name: String, age: Int){
        var stmt: OpaquePointer?
        //name은 string이기 때문에 따옴표로 묶어줌
        let queryString = "UPDATE myTable SET my_name='\(name)', my_age=\(age) WHERE id == \(id)"
        
        if sqlite3_prepare_v2(self.db, queryString, -1, &stmt, nil) != SQLITE_OK {
            onSQLErrorPrintErrorMessage(db)
            return
        }
        if sqlite3_step(stmt) != SQLITE_DONE{
            onSQLErrorPrintErrorMessage(db)
            return
        }
        print("Update has been successfully done")
    }
    
    func deleteTable(id: Int){
        let queryString = "DELETE FROM myTable WHERE id == \(id)"
        var stmt: OpaquePointer?
        
        if sqlite3_prepare_v2(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            onSQLErrorPrintErrorMessage(db)
            return
        }
        if(sqlite3_step(stmt) != SQLITE_DONE){
            onSQLErrorPrintErrorMessage(db)
            return
        }
        print("delete has been successfully done")
    }
    
    func deleteTable(tableName: String){
        let queryString = "DROP TABLE \(tableName)"
        var stmt: OpaquePointer?
        
        if sqlite3_prepare_v2(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            onSQLErrorPrintErrorMessage(db)
            return
        }
        if sqlite3_step(stmt) != SQLITE_DONE{
            onSQLErrorPrintErrorMessage(db)
            return
        }
        print("drop table has been successfully done")
    }
    
    
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    var dataArray: [MyModel] = []
    let dbHelper = DBHelper.shared
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: "tableViewCell") as? CustomTableViewCell else{ return UITableViewCell() }
        cell.id.text = String(dataArray[indexPath.row].id)
        cell.name.text = String(dataArray[indexPath.row].myName)
        if let age = dataArray[indexPath.row].myAge {
            cell.age.text = String(age)
        }
        return cell
    }
    
    @IBAction func tapCreateBtn(_ sender: UIButton) {
        dbHelper.createTable()
        self.dataArray = dbHelper.readData()
        self.tableView.reloadData()
    }
    
    @IBAction func tapInsertBtn(_ sender: UIButton) {
        dbHelper.insertData(name: "첫 번째", age: 10)
        dbHelper.insertData(name: "두 번째", age: 20)
        dbHelper.insertData(name: "세 번째", age: 30)
        
        self.dataArray = dbHelper.readData()
        print(dataArray)
        self.tableView.reloadData()
    }
    
    @IBAction func tapUpdateBtn(_ sender: UIButton) {
        dbHelper.updateData(id: 1, name: "수정한 첫 번째", age: 99)
        self.dataArray = dbHelper.readData()
        self.tableView.reloadData()
    }
    
    @IBAction func tapDeleteBtn(_ sender: UIButton) {
        dbHelper.deleteTable(id: 1)
        self.dataArray = dbHelper.readData()
        self.tableView.reloadData()
    }
    
    @IBAction func tapDropBtn(_ sender: UIButton) {
        dbHelper.deleteTable(tableName: "myTable")
        self.dataArray = dbHelper.readData()
        self.tableView.reloadData()
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        //sqlite 기본 구조 설명
        /*
        // Do any additional setup after loading the view.
        var db: OpaquePointer? = nil //aqlite 연결 정보를 담을 객체
        var stmt: OpaquePointer? = nil //컴파일된 sql을 담을 객체
        
        //디비 파일의 경로를 읽어오기
        //앱 내 문서 디렉터리 경로에서 sqlite db 파일을 찾는다
        
        //1. 파일 매니저 객체를 생성
        let fileMgr = FileManager()
        //2. 생성된 매니저 객체를 사용하여 앱 내의 문서 디렉터리경로를 찾고, 이를 url 객체로 생성
        let docPathURL = fileMgr.urls(for: .documentDirectory, in: .userDomainMask).first!
        //3. url객체에 db.sqlite 파일 경로를 추가한 aqlite3 데이터베이스 경로를 만들어낸다
        let dbPath = docPathURL.appendingPathComponent("db.sqlite").path
        
        let sql = "CREATE TABLE IF NOT EXITS sequence (num INTEGER)"
        
        //sqlite3 라이브러리에 정의된 함수들은 정상적으로 실행되었을 때 공통적으로 sqlite_ok상수를 반환한다
        //db를 연결하여 db객체가 생성
        if sqlite3_open(dbPath, &db) == SQLITE_OK { //db가 연결되었다면
            //sql 구문을 전달할 준비, 컴파일된 aql구문 객체가 생성(stmt)
            if sqlite3_prepare(db, sql, -1, &stmt, nil) == SQLITE_OK { //sql컴파일이 잘 끝났다면
                //컴파일된 aql구문 객체를 db에 전달
                if sqlite3_step(stmt) == SQLITE_DONE{
                    print("Create Table Success!")
                }
                //컴파일된 aql구문 객체를 삭제
                sqlite3_finalize(stmt)
            } else {
                print("Prepare Statement Fail")
            }
            //db연결 종료
            sqlite3_close(db)
            
        } else {
          print("Database Connect Fail")
            return
        }
        */
    }


}

