//
//  ListViewController.swift
//  MyMovieChart
//
//  Created by Kim Jun Soo on 08/01/2019.
//  Copyright © 2019 Kim Jun Soo. All rights reserved.
//

import UIKit
import Foundation

class ListViewController: UITableViewController {
    
    //현재까지 읽어온 데이터의 페이지 정보
    var page = 1
    //더보기 버튼 속성 컨트롤을 위한
    @IBOutlet var moreBtn: UIButton!
    
    //테이블 뷰를 구성할 리스트 데이터
    lazy var list : [MovieVO] = {
        var datalist  =  [MovieVO]()
        
        return datalist
    }()
    
    @IBAction func more(_ sender: UIButton) {
        //현재 페이지 값에 1을 추가한다.
        self.page += 1
        //영화차트 API를 호출한다.
        self.callMovieAPI()
        //데이터를 다시 읽어오도록 테이블 뷰를 갱신한다.
        self.tableView.reloadData()
    }
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.list.count
    }
   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //주어진 행에 맞는 데이터 소스를 읽어온다
        let row = self.list[indexPath.row]

        //로그 출력
        NSLog("제목:\(row.title!), 호출된 행번호 :\(indexPath.row)")
        //테이블 셀 객체를 직접 생성하는 대신 큐로부터 가져옴 -> MovieCell클래스로 변환
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell") as! MovieCell
        
        cell.title?.text = row.title
        cell.desc?.text = row.description
        cell.opendate?.text = row.opendate
        cell.rating?.text = "\(row.rating!)"
        
/*      1단계 메소드가 실행될 때마다 이미지를 받아와서 할당
         cell.thumbnail.image = UIImage(data: try! Data(contentsOf: URL(string: row.thumbnail!)!))
         2단계 이미지를 미리 MovieVO객체에 할당하여 리스트에 넣고 리스트에서 가져옴
            cell.thumbnail.image = row.thumbnailImage
*/
        //3단계 : DispatchQueue.main.async()를 통한 비동기 방식으로 이미지를 읽어옴
        DispatchQueue.main.async(execute: {
            NSLog("비동기 방식으로 실행되는 부분입니당")
            cell.thumbnail.image = self.getThumbnailImage(indexPath.row)
        })
        
//        //테그를 이용한 셀 데이터 삽입
//        let title = cell.viewWithTag(101) as? UILabel
//        let desc = cell.viewWithTag(102) as? UILabel
//        let opendate = cell.viewWithTag(103) as? UILabel
//        let rating = cell.viewWithTag(104) as? UILabel
//
//        title?.text = row.title
//        desc?.text = row.description
//        opendate?.text = row.opendate
//        rating?.text = "\(row.rating!)"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        NSLog("선택된 행은 \(indexPath.row)번째 행입니다.")
    }
    
    override func viewDidLoad() {
        //영화차트 API를 호출한다.
        self.callMovieAPI()
    }
    
    func callMovieAPI(){
        
        // 1. 호핀 API 호출을 위한 URI를 생성
        let url = "http://swiftapi.rubypaper.co.kr:2029/hoppin/movies?version=1&page=\(self.page)&count=30&genreId=&order=releasedateasc"
        let apiURI: URL! = URL(string: url)
        
        //2. REST API호출
        let apidata = try! Data(contentsOf: apiURI)
        
        //3. 데이터 전송 결과를 로그로 출력(반드시 필요한 코드는 아님)
        let log = NSString(data: apidata, encoding: String.Encoding.utf8.rawValue) ?? "데이터가 없습니다"
        NSLog("API Result = \(log)")
        
        //4. JSON 객체를 파싱하여 NSDictionary 객체로 변환
        do{
            let apiDictionary = try JSONSerialization.jsonObject(with: apidata, options: []) as! NSDictionary
            
            //5. 데이터 구조에 따라 차례대로 캐스팅하며 읽어온다.
            let hoppin = apiDictionary["hoppin"] as! NSDictionary
            let movies = hoppin["movies"] as! NSDictionary
            let movie = movies["movie"] as! NSArray
            
            //6. Itorator 처리를 하면서 API 데이터를 MovieVO객체에 저장한다.
            for row  in movie {
                //순회 상수를 NSDictionary 타입으로 캐스팅
                let r = row as! NSDictionary
                
                //테이블 뷰 리스트를 구성할 데이터 형식
                let mvo = MovieVO()
                
                //movie 배열의 각 데이터를 mvo 상수의 속성에 대입
                mvo.title       = r["title"] as? String
                mvo.description = r["genreNames"] as? String
                mvo.thumbnail   = r["thumbnailImage"] as? String
                mvo.detail      = r["linkUrl"] as? String
                mvo.rating      = (r["ratingAverage"] as! NSString).doubleValue
                
                /*네트워크 통신을 통해 읽어온 데이터는 재사용할 수 있도록 캐싱 처리하여 될 수 있으면 통신 횟수를 줄이는 것이 좋다.
                -> API를 불러올때 미리 이미지를 불러와 메모리에 할당, (메모이제이션 기법)
                -> 테이블 뷰에서 제거된 셀이 재사용 큐에 의해 다시 구성될 때를 위한 처리
                */
                let url : URL! = URL(string: mvo.thumbnail!)
                let imageData = try! Data(contentsOf: url)
                mvo.thumbnailImage = UIImage(data: imageData)
                
                //list 배열에 추가
                self.list.append(mvo)
            }
            //7. 전체 데이터 카운트를 얻는다.
            let totalCount = (hoppin["totalCount"] as? NSString)!.integerValue
            
            //8. totalCount가 읽어온 데이터 크기와 같거나 클 경우 더보기 버튼을 막는다.
            if(self.list.count >= totalCount){
                self.moreBtn.isHidden = true
            }
        }catch{
            NSLog("Parse Error!!")
        }
    }
    func getThumbnailImage(_ index: Int) -> UIImage {
        //인자값으로 받은 인덱스를 기반으로 해당하는 배열 데이터를 읽어옴
        let mvo = self.list[index]
        
        //메모이제이션 : 저장된 이미지가 있으면 그것을 반환하고, 없을 경우 내려받아 저장한 후 반환
        if let savedImage = mvo.thumbnailImage{
            return savedImage
        }else{
            let url: URL! = URL(string: mvo.thumbnail!)
            let imageData = try! Data(contentsOf: url)
            mvo.thumbnailImage = UIImage(data: imageData) // UIImage를 MovieVO 객체에 우선저장
            return mvo.thumbnailImage! // 저장된 이미지 반환
        }
    }
}
//MARK: - 화면 전환시 값을 넘겨주기 위한 세그웨이 관련 처리
extension ListViewController{
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //실행된 세그웨이의 식별자가 "segue_detail" 이라면
        if segue.identifier == "segue_detail" {
            //sender 인자를 캐스팅하여 테이블 셀 객체로 변환한다.
            let cell = sender as! MovieCell
            
            //사용자가 클릭한 행을 찾아낸다
            let path = self.tableView.indexPath(for: cell)
            
            //API 영화 데이터 배열 중에서 선택된 행에 대한 데이터를 추출한다.
            let movieinfo = self.list[path!.row]
            
            //행 정보를 통해 선택된 영화 데이터를 찾은 다음, 목적지 뷰 컨트롤러의 mvo 변수에 대입한다.
            let detailVC = segue.destination as? DetailViewController
            detailVC?.mvo = movieinfo
        }
    }
}
