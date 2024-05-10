import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class FirebaseDatabase{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> AddToDo(String title)async{
    try{
      var uuid = Uuid().v4();
      await _firestore
          .collection('Users')
          .doc(_auth.currentUser!.uid)
          .collection("todo")
          .get({"id": uuid, "todoText": title, "isDone": false,} as GetOptions?);
      return true;
    }
    catch(ex){
      return true;
    }
  }
}