//
//  ProfileViewController.swift
//  Smartketo
//
//  Created by Pubudu Dilshan on 2023-05-16.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    
    
    //profile pic
    // full name
    // email
    //list of posts
    private var user: User?
    
    private let tableView: UITableView = {
        
        let tableView = UITableView()
        tableView.register(PostPreviewUITableViewCell.self, forCellReuseIdentifier: PostPreviewUITableViewCell.identifier)
        
        return tableView
    }()
    let currentEmail: String
    init(currentEmail: String) {
        self.currentEmail = currentEmail
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init(coder:NSCoder) {
        fatalError()
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupSignOutButton()
        setUpTable()
        title = "Profile"
        fetchPosts()
        
        
     
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        
    }
    
    private func setUpTable(){
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        setUpTableHeader()
        fetchProfileData()
    }
    
    private func setUpTableHeader(profilePhotoRef: String? = nil, name: String? = nil){
        let headerView = UIView(frame:CGRect(x: 0, y: 0, width: view.width, height: view.width/1.5))
        headerView.backgroundColor = .systemBlue
        headerView.isUserInteractionEnabled = true
        headerView.clipsToBounds  = true
        tableView.tableHeaderView = headerView
        //profile picture
        let profilePhoto = UIImageView(image: UIImage(systemName: "person.circle"))
        profilePhoto.tintColor = .white
        profilePhoto.contentMode = .scaleAspectFit
        profilePhoto.frame = CGRect(x: (view.width - (view.width/4))/2,
                                    y: (headerView.height - (view.width/4))/2.5,
                                    width: view.width/4, height: view.width/4)
        
        profilePhoto.layer.masksToBounds = true
        profilePhoto.layer.cornerRadius = profilePhoto.width/2
        profilePhoto.isUserInteractionEnabled = true
        headerView.addSubview(profilePhoto)
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapProfilePhoto))
        profilePhoto.addGestureRecognizer(tap)
        //Name
        //Email
        let emailLabel = UILabel(frame: CGRect(x: 20,
                                               y: profilePhoto.bottom+10,
                                               width: view.width-40,
                                               height: 100))
        
        headerView.addSubview(emailLabel)
        emailLabel.text = currentEmail
        emailLabel.textAlignment = .center
        emailLabel.textColor = .white
        emailLabel.font = .systemFont(ofSize: 25, weight: .bold)
    
        if let name = name{
            
            title = name
        }
        if let ref = profilePhotoRef{
            //fetch image
            
            StorageManager.shared.downloadUrlForProfilePicture(path: ref){ url in
                guard let url = url else {
                    return
                }
                let task = URLSession.shared.dataTask(with: url){ data, _, _ in
                    guard let data = data else {
                        return
                    }
                    DispatchQueue.main.async {
                        profilePhoto.image = UIImage(data: data)
                    }
                }
                task.resume()
                
            }
        
        }
        
    }
    @objc private func didTapProfilePhoto(){
        guard let myEmail = UserDefaults.standard.string(forKey: "email"),
        myEmail == currentEmail
        else {
            return
        }
        
    
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    private func  fetchProfileData(){
        DatabaseManager.shared.getUser(email: currentEmail){
            [weak self]user in
            guard let user = user else {
                
                return
            }
            self?.user = user
            DispatchQueue.main.async {
                self?.setUpTableHeader(profilePhotoRef: user.profilePictureRef,
                                        name: user.name)
            }
        }
    }
    
    private func setupSignOutButton(){
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title:"SignOut", style: .done, target: self, action: #selector(didTapSignOut))
        
    }
    
   @objc private func didTapSignOut(){
        
       AuthManager.shared.signOut{[weak self]success in
           if success {
               DispatchQueue.main.async {
                   
                   UserDefaults.standard.set(nil, forKey: "email")
                   UserDefaults.standard.set(nil, forKey: "name")
                   
                   let nextScreen = SignInViewController()
                   self?.present(nextScreen, animated: true)

               }
           }
           
       }
    }
    //TableView
    
    private var posts: [BlogPost] = []
    
    private func fetchPosts(){
        
        
        print("fetching post..")
        DatabaseManager.shared.getPosts(for: currentEmail){[weak self]posts in
            self?.posts = posts
            print("Found \(posts.count) posts")
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let post = posts[indexPath.row]
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier:PostPreviewUITableViewCell.identifier, for: indexPath) as?
                PostPreviewUITableViewCell else{
            fatalError()
            
        }
        
        cell.configure(with: .init(title: post.title,imageUrl: post.headerImageUrl))
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    //viewing the work out 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
//        let vc = PostViewController()
        let vc = ViewPostViewController(post: posts[indexPath.row])
        vc.title = posts[indexPath.row].title
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[.editedImage] as? UIImage else {
            
            return
        }
        StorageManager.shared.uploadProfilePicture(email: currentEmail,
                                                   image: image){[weak self] success in
            guard let strongSelf = self else {return}
            if success {
                //update database
                DatabaseManager.shared.updateProfilePhoto(email:strongSelf.currentEmail){updated in
                    guard updated else {
                        return
                    }
                    DispatchQueue.main.self.async {
                        strongSelf.fetchProfileData()
                    }
                    
                }
            }
        }
    }
    
}
