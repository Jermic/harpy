import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';
import 'package:harpy/components/screens/main/main_screen.dart';
import 'package:harpy/components/screens/user_profile/user_profile_screen.dart';
import 'package:harpy/stores/home_store.dart';
import 'package:harpy/stores/login_store.dart';
import 'package:harpy/stores/tokens.dart';
import 'package:harpy/stores/user_store.dart';

class HomeDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          UserDrawerHeader(),
          _buildActions(),
          _buildBottomActions(context),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Column(
      children: <Widget>[
        ListTile(
          leading: Icon(Icons.face),
          title: Text("Profile"),
          onTap: () {},
        ),
        ListTile(
          leading: Icon(Icons.bookmark_border),
          title: Text("Bookmarks"),
          onTap: () {},
        ),
        ListTile(
          leading: Icon(Icons.close),
          title: Text("Clear cache"),
          onTap: HomeStore.clearCache,
        ),
      ],
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Expanded(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ListTile(
          leading: Icon(Icons.arrow_back),
          title: Text("Logout"),
          onTap: () => logoutAndNavigateBack(context),
        ),
      ),
    );
  }

  Future<void> logoutAndNavigateBack(BuildContext context) async {
    await LoginStore.twitterLogout();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainScreen()),
    );
  }
}

/// The [Drawer] header that contains information about the logged in [User].
class UserDrawerHeader extends StatefulWidget {
  @override
  _UserDrawerHeaderState createState() => _UserDrawerHeaderState();
}

class _UserDrawerHeaderState extends State<UserDrawerHeader>
    with StoreWatcherMixin {
  UserStore store;

  @override
  void initState() {
    super.initState();
    store = listenToStore(Tokens.user);
  }

  @override
  void dispose() {
    super.dispose();
    unlistenFromStore(store);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => UserProfileScreen(
                      user: store.loggedInUser,
                    )),
          ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8.0),
        padding: EdgeInsets.fromLTRB(
          16.0,
          16.0 + MediaQuery.of(context).padding.top, // + statusbar height
          16.0,
          8.0,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: Divider.createBorderSide(context),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(width: double.infinity),
            CircleAvatar(
              radius: 32.0,
              backgroundColor: Colors.transparent,
              backgroundImage: CachedNetworkImageProvider(
                store.loggedInUser.userProfileImageOriginal,
              ),
            ),
            SizedBox(height: 8.0),
            Text(store.loggedInUser.name,
                style: Theme.of(context).textTheme.display2),
            Text("@${store.loggedInUser.screenName}",
                style: Theme.of(context).textTheme.display1),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: <Widget>[
                  Text(
                    "Followers: ${store.loggedInUser.followersCount}",
                    style: Theme.of(context).textTheme.display1,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Following: ${store.loggedInUser.friendsCount}",
                      style: Theme.of(context).textTheme.display1,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
