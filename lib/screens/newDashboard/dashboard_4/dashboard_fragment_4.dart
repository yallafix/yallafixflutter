import 'package:booking_system_flutter/screens/newDashboard/dashboard_4/component/app_bar_dashboard_component_4.dart';
import 'package:booking_system_flutter/screens/newDashboard/dashboard_4/component/service_list_dashboard_component_4.dart';
import 'package:booking_system_flutter/screens/newDashboard/dashboard_4/component/upcoming_booking_dashboard_component_4.dart';
import 'package:booking_system_flutter/screens/newDashboard/dashboard_4/shimmer/dashboard_shimmer_4.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../component/empty_error_state_widget.dart';
import '../../../component/loader_widget.dart';
import '../../../main.dart';
import '../../../model/dashboard_model.dart';
import '../../../network/rest_apis.dart';
import '../../../utils/colors.dart';
import '../../../utils/constant.dart';
import 'component/category_list_dashboard_component_4.dart';
import 'component/job_request_dashboard_component_4.dart';
import 'component/slider_dashboard_component_4.dart';

class DashboardFragment4 extends StatefulWidget {
  @override
  _DashboardFragment4State createState() => _DashboardFragment4State();
}

class _DashboardFragment4State extends State<DashboardFragment4> {
  Future<DashboardResponse>? future;

  @override
  void initState() {
    super.initState();
    init();

    setStatusBarColor(transparentColor, delayInMilliSeconds: 800);

    LiveStream().on(LIVESTREAM_UPDATE_DASHBOARD, (p0) {
      init();
      appStore.setLoading(true);

      setState(() {});
    });
  }

  void init() async {
    future = userDashboard(isCurrentLocation: appStore.isCurrentLocation, lat: getDoubleAsync(LATITUDE), long: getDoubleAsync(LONGITUDE));
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
    LiveStream().dispose(LIVESTREAM_UPDATE_DASHBOARD);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appStore.isDarkMode ? context.primaryColor.withOpacity(0.01) : primaryLightColor,
      body: Stack(
        children: [
          SnapHelperWidget<DashboardResponse>(
            initialData: cachedDashboardResponse,
            future: future,
            errorBuilder: (error) {
              return NoDataWidget(
                title: error,
                imageWidget: ErrorStateWidget(),
                retryText: language.reload,
                onRetry: () {
                  appStore.setLoading(true);
                  init();

                  setState(() {});
                },
              );
            },
            loadingWidget: DashboardShimmer4(),
            onSuccess: (snap) {
              return AnimatedScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                listAnimationType: ListAnimationType.FadeIn,
                fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
                onSwipeRefresh: () async {
                  appStore.setLoading(true);

                  setValue(LAST_APP_CONFIGURATION_SYNCED_TIME, 0);
                  init();
                  setState(() {});

                  return await 2.seconds.delay;
                },
                children: [
                  AppBarDashboardComponent4(
                    featuredList: snap.featuredServices.validate(),
                    callback: () {
                      appStore.setLoading(true);

                      init();
                      setState(() {});
                    },
                  ),
                  40.height,
                  CategoryListDashboardComponent4(categoryList: snap.category.validate(), listTiTle: language.category),
                  UpComingBookingDashboardComponent4(upComingBookingData: snap.upcomingData),
                  30.height,
                  SliderDashboardComponent4(sliderList: snap.slider.validate()),
                  30.height,
                  ServiceListDashboardComponent4(
                    serviceList: snap.service.validate(),
                    serviceListTitle: language.service,
                  ),
                  16.height,
                  ServiceListDashboardComponent4(
                    serviceList: snap.featuredServices.validate(),
                    serviceListTitle: language.featuredServices,
                    isFeatured: true,
                  ),
                  16.height,
                  if (appConfigurationStore.jobRequestStatus) JobRequestDashboardComponent4()
                ],
              );
            },
          ),
          Observer(builder: (context) => LoaderWidget().visible(appStore.isLoading)),
        ],
      ),
    );
  }
}
