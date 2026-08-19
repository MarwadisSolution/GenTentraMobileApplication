import 'dart:convert';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class OfflineFeedDatabase {

  OfflineFeedDatabase._();
  static final OfflineFeedDatabase instance=OfflineFeedDatabase._();

  Database? _database;
  Future<Database>get database async{
    if(_database!=null){
      return _database!;
    }
    _database=await _initDatabase();
    return _database!;
  }
  Future<Database> _initDatabase()async{
    final dbPath=await getDatabasesPath();
    final path=join(
      dbPath,
      'gententra_feed.db',
    );
    return openDatabase(
        path,
      version: 1,
      onCreate: (db, version)async{
          await db.execute(
            ''' 
            CREATE TABLE pending_posts(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            payload TEXT NOT NULL,
            media_paths TEXT NOT NULL,
            created_at TEXT NOT NULL,
            retry_count INTEGER NOT NULL DEFAULT 0,
            status TEXT NOT NULL DEFAULT 'pending'
            )
            '''
          );
      }
    );
  }
  Future<int>insertPendingPost({
    required Map<String, dynamic>payload,
    required List<String>mediaPaths,
})async{
    final db=await database;
    return db.insert(
      'pending_posts',
      {
        'payload':jsonEncode(payload),
        'media_paths':jsonEncode(mediaPaths),
        'created_at': DateTime.now().toIso8601String(),
        'retry_count':0,
        'status':'pending',
      }
    );
  }
  Future<List<Map<String, dynamic>>>getPendingPosts()async{
    final db=await database;
    return db.query(
      'pending_posts',
      where: 'status = ?',
      whereArgs: ['pending'],
      orderBy: 'created_at ASC',
    );
  }
  Future<void>deletePost(int id)async{
    final db=await database;
    await db.delete(
      'pending_posts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  Future<void> incrementRetryCount(int id)async{
    final db=await database;
    await db.rawUpdate(
      '''
      UPDATE pending_posts
      SET retry_count = retry_count + 1
      WHERE id = ?
      ''',
      [id],
    );
  }
  Future<int>pendingCount()async{
    final db=await database;
    final result =await db.rawQuery(
      '''
      SELECT COUNT(*) as count
      FROM pending_posts
      WHERE status = ?
      ''',
      ['pending'],
    );
    return Sqflite.firstIntValue(result)??0;
  }
}