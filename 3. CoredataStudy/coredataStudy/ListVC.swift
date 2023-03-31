//
//  ListVC.swift
//  coredataStudy
//
//  Created by Mac on 2023/03/28.
//

import UIKit
import CoreData



class ListVC: UITableViewController {
    
    //listVC에서 Accessory View 버튼을 누르면 LogVC로 화면 전환하는 동시에 board값을 동시에 넘김
    //엔터티 설정에서 Board, List 릴레이션 이름을 각각 "board","logs"로 했으므로, "boardMO객체.logs.array"(1:M)로 접근 가능
    var board: BoardMO!
    
   
    //lazy var list: [NSManagedObject]! = {
    //    return self.board.logs?.array as! [LogMO]
    //}()
    //데이터 소스 역할을 할 배열 변수
    
    lazy var list: [NSManagedObject] = {
        return self.fetch()
    }()
     
    
    //MARK: 데이터 가져오기
    func fetch() -> [NSManagedObject] {
        //1.앱 델리게이트 객체 참조
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //2.관리 객체 컨텍스트 참조
        let context = appDelegate.persistentContainer.viewContext
        //3.요청 객체 생성 (코어 데이터에 저장된 데이터를 가져올 때는 요청 사항을 정의한 NSFetchRequest객체가 사용)
        /*
        //이 객체는 다양한 요청들을 복합적으로 정의
         1. 어디서 데이터를 가져올 것인가? <필수> (엔터티 지정) -> select 구문에서 from에 해당
         2. 어떤 데이터를 가져올 것인가? (검색 조건 지정) -> where 조건절에 해당
         3. 어떻게 데이터를 가져올 것인가? (정렬 조건 지정) -> order by에 해당
         */
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Board")
        
        //MARK: 정렬하기
        //3-1. 정렬 속성 설정
        //어느 어트리뷰트를 기준으로 정렬할 것인가, 어떤 순서로 정렬할 것인가 (true-오름차순)
        let sort = NSSortDescriptor(key: "regdate", ascending: false)
        //NSSortDescriptor 객체는 fetchRequest.sortDescriptor 속성에 할당됨으로써 요청 객체의 일부로 동작하게 된다
        //배열일 경우 두개 이상의 NSSortDescruptor 객체를 정의하여 대입할 수 있다 -> 두가지 이상의 정렬 기준을 차례대로 적용할 수 있다
        fetchRequest.sortDescriptors = [sort]
        
        //4.데이터(레코드) 가져오기
        //-> NSManagedObject 또는 그 하위 타입의 인스턴스로 이루어진 배열을 반환
        //배열을 이루는 각각의 인스턴스가 관리 객체
        let result = try! context.fetch(fetchRequest)
        return result
    }
    
    //MARK: 등록 기능
    /*
     1. 빈 관리 객체를 생성하고, 이를 컨텍스트 객체에 등록
     2. 생성된 관리 객체에 값을 채워 넣음
     3. 컨텍스트 객체의 변경 사항을 영구 저장소에 반영 -> 커밋/동기화라고 부름
     */
    func save(title: String, contents: String) -> Bool {
        //1. 앱 델리게이트 객체 참조
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //2. 관리 객체 컨텍스트 참조
        let context = appDelegate.persistentContainer.viewContext
        
        //3. 관리 객체 생성 & 값을 생성
        //관리 객체는 생성과 동시에 컨텍스트 객체의 관리 하에 있어야 하기 때문에, 기본 초기화 메소드를 이용해서 객체만 생성할 경우 런타임 오류가 발생, 반드시 관리 객체를 생성하여 컨텍스트 객체가 관리할 수 있도록 해주어야 한다
        let object = NSEntityDescription.insertNewObject(forEntityName: "Board", into: context)
        object.setValue(title, forKey: "title")
        object.setValue(contents, forKey: "contents")
        object.setValue(Date(), forKey: "regdate")
        
        //4. 영구 저장소에 commit후에 list 프로퍼티 추가
        do{
            try context.save()
            //self.list.append(object)
            self.list.insert(object, at: 0)
            return true
        } catch let error as NSError {
            //동기화에 실패했을 경우 마지막 동기화 시점 이후의 모든 변경 내역을 원래대로 되돌림
            //영구 저장소에 커밋이 실패했다 하더라도 현재의 컨텍스트에는 새로 생성된 객체가 남아있게되므로, 이를 그대로 두면 실제 저장소와 일시적으로 데이터가 일치하지 않는 무제가 발생 -> 이를 방지하기 위해서 롤백
            context.rollback()
            return false
        }
    }
    
    //MARK: 삭제 기능
    func delete(object: NSManagedObject) -> Bool {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        context.delete(object)
        
        do{
            try context.save()
            return true
        } catch {
            context.rollback()
            return false
        }
    }
    
    //MARK: 수정하기
    //수정 작업은 이미 컨텍스트에 로딩되어 있는 관리 객체에서 이루어져야 한다
    //수정할 NSManagedObject(관리 객체)를 파라미터로 받아서 덮어쓴 후 context로 영구 저장소에 저장
    func update(object: NSManagedObject, title: String, contents: String) -> Bool {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        object.setValue(title, forKey: "title")
        object.setValue(contents, forKey: "contents")
        object.setValue(Date(), forKey: "regdate")
        
        //영구 저장소에 반영
        do {
            try context.save()
            self.list = self.fetch() //list 배열을 갱신
            return true
        } catch {
            context.rollback()
            return false
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let addBtn = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add))
        self.navigationItem.rightBarButtonItem = addBtn
    }
    
    @objc func add(_ sender: Any){
        let alert = UIAlertController(title: "게시글 등록", message: nil, preferredStyle: .alert)
        //입력 필드 추가(이름 & 전화번호)
        //인자값 표기
        alert.addTextField() {$0.placeholder = "제목"}
        alert.addTextField() {$0.placeholder = "내용"}
        
        //버튼 추가(Cancel & Save)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { _ in
            guard let title = alert.textFields?.first?.text, let contents = alert.textFields?.last?.text else {
                return
            }
            //값을 저장하고, 성공이면 테이블 뷰를 리로드 한다.
            if self.save(title: title, contents: contents) == true {
                self.tableView.reloadData()
            }
        }) //end of alert.addAction
        self.present(alert, animated: false)
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let object = self.list[indexPath.row] //삭제할 대상 NSManagedObject 객체
        if self.delete(object: object){ //db에서 삭제
            //코어데이터에서 삭제되고 나면 배열 목록과 테이블 뷰의 행도 삭제된다
            self.list.remove(at: indexPath.row)//데이터 삭제
            self.tableView.deleteRows(at: [indexPath], with: .fade)//테이블뷰에서 해당 행을 fade 방법으로 제거
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.list.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //해당하는 데이터 가져오기
        let record = self.list[indexPath.row]
        //list배열 내부 타입은 NSManageObject이기 때문에 원하는 적절한 캐스팅이 필요함(Any->String)
        let title = record.value(forKey: "title") as? String
        let contents = record.value(forKey: "contents") as? String
        
        //셀을 생성하고 값을 대입
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = title
        cell.detailTextLabel?.text = contents

        // Configure the cell...

        return cell
    }
    
    //여러개의 객체를 한꺼번에 수정해야한다면 매번 save()를 호출할 필요 x -> 어차피 save 메소드가 호출되면 그동안 컨텍스트에서 발생한 변경 내용을 모두 동기화하기 때문에 한번만 호출해줘도 지금까지 변경된 내용 반영됨
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //1. 선택된 행에 해당하는 데이터 가져오기
        let object = self.list[indexPath.row]
        let title = object.value(forKey: "title") as? String
        let contents = object.value(forKey: "contents") as? String
        
        let alert = UIAlertController(title: "게시글 수정 ", message: nil, preferredStyle: .alert)
        
        //2. 입력 필드 추가(기존 값 입력)
        alert.addTextField() {$0.text = title}
        alert.addTextField() {$0.text = contents}
        
        //3. 버튼 추가(Cancel & Save)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { _ in
            guard let title = alert.textFields?.first?.text, let contents = alert.textFields?.last?.text else {
                return
            }
            //값을 수정하는 메소드를 호출하고, 성공이면 테이블 뷰를 리로드 한다.
            if self.update(object: object, title: title, contents: contents) == true {
                //self.tableView.reloadData()
                //1) 셀의 내용을 직접 수정한다
                let cell = self.tableView.cellForRow(at: indexPath)
                cell?.textLabel?.text = title
                cell?.detailTextLabel?.text = contents
                
                //2) 수정된 셀을 첫 번째 행으로 이동 시킨다
                let firstIndexPath = IndexPath(item: 0,section: 0)
                self.tableView.moveRow(at: indexPath, to: firstIndexPath)
            }
        }) //end of alert.addAction
        self.present(alert, animated: false)
    }

}
