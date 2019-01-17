//
//  DetailViewController.swift
//  MyMovieChart
//
//  Created by Kim Jun Soo on 10/01/2019.
//  Copyright © 2019 Kim Jun Soo. All rights reserved.
//

import UIKit
import WebKit

class DetailViewController: UIViewController {
    
    @IBOutlet var wv: WKWebView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    
    var mvo = MovieVO() //목록 화면에서 전달하는 영화 정보를 받을 변수
    
    override func viewDidLoad() {
        //WKNavigationDelegate의 델리게이트 객체를 지정
        self.wv.navigationDelegate = self

        NSLog("\(self.mvo.detail!), title=\(self.mvo.title!)")
        
        //내비게이션 바의 타이틀에 영화명을 입력한다
        let navibar = self.navigationItem
        navibar.title = self.mvo.title
        
        if let url = self.mvo.detail{
            if let urlObj = URL(string: url){
                let req = URLRequest(url: urlObj)
                self.wv.load(req)
            }else{//URL 형식이 잘못되었을 경우에 대한 예외처리
                //경고창 형식으로 오류메세지를 보낸다
                let alert = UIAlertController(title: "오류", message: "잘못된 URL입니다.", preferredStyle: .alert)
                let cancelAction  = UIAlertAction(title: "확인", style: .cancel){(_) in
                    //이전페이지로 돌려보낸다.
                    _ = self.navigationController?.popViewController(animated: true)
                }
                alert.addAction(cancelAction)
                self.present(alert, animated: false)
            }
        }else{//URL값이 전달되지 않았을 경우에 대한 예외처리
            //경고창 형식으로 오류메세지를 표시해준다
            let alert = UIAlertController(title: "오류", message: "필수 파라미터가 누락되었습니다.", preferredStyle: .alert)
            let cancelAction  = UIAlertAction(title: "확인", style: .cancel){(_) in
                //이전페이지로 돌려보낸다.
                _ = self.navigationController?.popViewController(animated: true)
            }
            alert.addAction(cancelAction)
            self.present(alert, animated: false)
        }
        
    }
}
//MARK: - WKNavigationDelegate 프로토콜 구현
extension DetailViewController : WKNavigationDelegate{
    //웹 콘텐츠를 받기 시작할때 호출
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        self.spinner.startAnimating()//인디케이터 뷰의 애니메이션을 실행
    }
    //웹 콘텐츠 로딩을 완전히 마쳤을때 호출
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        /* 인디케이터 뷰의 애니메이션 중단, 중단하는것만으로 인디케이터 뷰가 사라지는 것은 [Hides When Stopped] 속성에 체크했기 때문 */
        self.spinner.stopAnimating()
    }
    //웹 콘텐츠 로딩에 실패했을때
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.spinner.stopAnimating() //인디케이터 뷰의 애니메이션 중지
        self.alert("상세 페이지를 읽어오지 못했습니다."){
            //이전화면으로 돌려보냄
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        self.spinner.stopAnimating() //인디케이터 뷰의 애니메이션 중지
        self.alert("상세 페이지를 읽어오지 못했습니다."){
            //이전화면으로 돌려보냄
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
}
//MARK: - 심플한 경고창 함수 정의용 익스텐션
extension UIViewController{
    func alert(_ message: String, onClick: (() -> Void)? = nil){
        let controller = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "OK", style: .cancel){(_) in
            onClick?()
        })
        DispatchQueue.main.async {
            self.present(controller, animated: false)
        }
    }
}
