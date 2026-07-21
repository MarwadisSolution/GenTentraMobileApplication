import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Favourite/favourite_page_modal.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavouritePageCaching {
  static const String _key = "favourite_parties";

  ///----Loading all favourites
  Future<List<FavouritePageModal>> getFavourites() async {
    final pref = await SharedPreferences.getInstance();
    final data = pref.getString(_key);
    if (data == null || data.isEmpty) {
      return [];
    }
    return FavouritePageModal.decode(data);
  }

  ///----------Now checking is party favourite
  Future<bool> isFavourite(int id) async {
    final favourites = await getFavourites();
    return favourites.any((e) => e.id == id);
  }

  ///----Adding party for favourite
  Future<void> addFavourite(FavouritePageModal party) async {
    final pref = await SharedPreferences.getInstance();
    final favourites = await getFavourites();
    if (!favourites.any((e) => e.id == party.id)) {
      favourites.add(party);
      await pref.setString(_key, FavouritePageModal.encode(favourites));
    }
  }

  ///--------Removing party fro caching
Future<void>removeFavourite(int id)async{
    final pref=await SharedPreferences.getInstance();
    final favourite=await getFavourites();
    favourite.removeWhere((e)=>e.id==id);
    await pref.setString(_key, FavouritePageModal.encode(favourite));
}
}
