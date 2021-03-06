import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/generated/i18n.dart';
import 'package:food_delivery_app/src/controllers/res_categories_controller.dart';
import 'package:food_delivery_app/src/elements/ResCatListItemWidget.dart';
import 'package:food_delivery_app/src/helpers/app_config.dart' as config;
import 'package:food_delivery_app/src/models/res_category.dart';
import 'package:food_delivery_app/src/models/route_argument.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:location/location.dart' as location;
class ResCategoriesWidget extends StatefulWidget {
  RouteArgument routeArgument;

  ResCategoriesWidget({Key key, this.routeArgument}) : super(key: key);

  @override
  _ResCategoriesWidgetState createState() => _ResCategoriesWidgetState();
}

class _ResCategoriesWidgetState extends StateMVC<ResCategoriesWidget> {
  ResCategoriesController _con;
  LocationAccuracy desiredAccuracy = LocationAccuracy.best;
  _ResCategoriesWidgetState() : super(ResCategoriesController()) {
    _con = controller;
  }

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    if (widget.routeArgument != null) {
      _con.resCategories = widget.routeArgument.param;
    } else {
      _con.listenForResCategories();
    }
  }
  void getCurrentLocation() async
  {
    GeolocationStatus geolocationStatus =
        await Geolocator().checkGeolocationPermissionStatus();
    print('geolocationStatus.value:${geolocationStatus.value}');
    if (geolocationStatus.value == 2) {
      ServiceStatus serviceStatus =
          await LocationPermissions().checkServiceStatus();
      print('serviceStatus:$serviceStatus');
      if (serviceStatus == ServiceStatus.enabled) {
        Geolocator()
            .getCurrentPosition(desiredAccuracy: desiredAccuracy)
            .then((position) async {
          if (position != null) {
            print('new lat:${position.latitude}');
            print('new long:${position.longitude}');
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setDouble('currentLat', position.latitude);
            await prefs.setDouble('currentLon', position.longitude);
          } else {
            print('position null');
          }
        });
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: config.Colors().mainColor(1),
        body: _con.resCategories.isEmpty
            ? Center(
                child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).scaffoldBackgroundColor),
              ))
            : Center(
                child: Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 50,
                        color: Theme.of(context).hintColor.withOpacity(0.2),
                      )
                    ]),
                margin: EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                padding: EdgeInsets.symmetric(vertical: 50, horizontal: 27),
                width: config.App(context).appWidth(88),
//              height: config.App(context).appHeight(55),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      S.of(context).res_categories_title,
                      style: Theme.of(context).textTheme.display1.merge(
                          TextStyle(
                              fontSize: 24,
                              color: config.Colors().mainColor(1))),
                    ),
                    ListView.separated(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      primary: false,
                      itemCount: _con.resCategories.length,
                      separatorBuilder: (context, index) {
                        return SizedBox(height: 10);
                      },
                      itemBuilder: (context, index) {
                        return ResCatListItemWidget(
                          heroTag: 'res_cat_list',
                          resCategory: _con.resCategories.elementAt(index),
                        );
                      },
                    )
                  ],
                ),
              )));
  }
}
