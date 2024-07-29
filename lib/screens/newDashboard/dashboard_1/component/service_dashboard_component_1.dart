import 'package:booking_system_flutter/utils/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../../component/cached_image_widget.dart';
import '../../../../component/image_border_component.dart';
import '../../../../component/online_service_icon_widget.dart';
import '../../../../component/price_widget.dart';
import '../../../../main.dart';
import '../../../../model/service_data_model.dart';
import '../../../../utils/colors.dart';
import '../../../../utils/common.dart';
import '../../../../utils/constant.dart';
import '../../../../utils/images.dart';
import '../../../booking/provider_info_screen.dart';
import '../../../service/service_detail_screen.dart';

class ServiceDashboardComponent1 extends StatefulWidget {
  final ServiceData serviceData;
  final double? width;
  final bool? isBorderEnabled;
  final VoidCallback? onUpdate;
  final bool isFavouriteService;
  final bool isFromDashboard;

  ServiceDashboardComponent1({
    required this.serviceData,
    this.width,
    this.isBorderEnabled,
    this.isFavouriteService = false,
    this.onUpdate,
    this.isFromDashboard = false,
  });

  @override
  _ServiceDashboardComponent1State createState() => _ServiceDashboardComponent1State();
}

class _ServiceDashboardComponent1State extends State<ServiceDashboardComponent1> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        hideKeyboard(context);
        ServiceDetailScreen(
          serviceId: widget.isFavouriteService ? widget.serviceData.serviceId.validate().toInt() : widget.serviceData.id.validate(),
        ).launch(context).then((value) {
          setStatusBarColor(context.primaryColor);
        });
      },
      child: Container(
        decoration: boxDecorationWithRoundedCorners(
          borderRadius: radius(),
          backgroundColor: context.cardColor,
          border: widget.isBorderEnabled.validate(value: false)
              ? appStore.isDarkMode
                  ? Border.all(color: context.dividerColor)
                  : null
              : null,
        ),
        width: widget.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 180,
              width: context.width(),
              child: Stack(
                children: [
                  CachedImageWidget(
                    url: widget.isFavouriteService
                        ? widget.serviceData.serviceAttachments.validate().isNotEmpty
                            ? widget.serviceData.serviceAttachments.validate().first.validate()
                            : ''
                        : widget.serviceData.attachments.validate().isNotEmpty
                            ? widget.serviceData.attachments!.first.validate()
                            : '',
                    fit: BoxFit.cover,
                    height: 180,
                    width: context.width(),
                    circle: false,
                  ).cornerRadiusWithClipRRectOnly(topRight: defaultRadius.toInt(), topLeft: defaultRadius.toInt()),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                      constraints: BoxConstraints(maxWidth: context.width() * 0.3),
                      decoration: boxDecorationWithShadow(
                        backgroundColor: context.cardColor.withOpacity(0.9),
                        borderRadius: radius(24),
                      ),
                      child: Marquee(
                        directionMarguee: DirectionMarguee.oneDirection,
                        child: Text(
                          "${widget.serviceData.subCategoryName.validate().isNotEmpty ? widget.serviceData.subCategoryName.validate() : widget.serviceData.categoryName.validate()}".toUpperCase(),
                          style: boldTextStyle(color: appStore.isDarkMode ? white : Colors.black, size: 10),
                        ).paddingSymmetric(horizontal: 8, vertical: 4),
                      ),
                    ),
                  ),
                  if (widget.isFavouriteService)
                    Positioned(
                      top: 12,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(8),
                        margin: EdgeInsets.only(right: 8),
                        decoration: boxDecorationWithShadow(boxShape: BoxShape.circle, backgroundColor: context.cardColor),
                        child: widget.serviceData.isFavourite == 1 ? ic_fill_heart.iconImage(color: favouriteColor, size: 18) : ic_heart.iconImage(color: unFavouriteColor, size: 18),
                      ).onTap(() async {
                        if (widget.serviceData.isFavourite == 0) {
                          widget.serviceData.isFavourite = 1;
                          setState(() {});

                          await removeToWishList(serviceId: widget.serviceData.serviceId.validate().toInt()).then((value) {
                            if (!value) {
                              widget.serviceData.isFavourite = 0;
                              setState(() {});
                            }
                          });
                        } else {
                          widget.serviceData.isFavourite = 0;
                          setState(() {});

                          await addToWishList(serviceId: widget.serviceData.serviceId.validate().toInt()).then((value) {
                            if (!value) {
                              widget.serviceData.isFavourite = 1;
                              setState(() {});
                            }
                          });
                        }
                        widget.onUpdate?.call();
                      }),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                16.height,
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: 0, right: 16, top: 0, bottom: 0),
                      decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(24)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 26,
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
                            child: Icon(Icons.star, color: Colors.white, size: 15),
                          ),
                          8.width,
                          Text(
                            widget.serviceData.totalRating.validate().toString(),
                            style: boldTextStyle(size: 12, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                    if (widget.serviceData.isOnlineService) OnlineServiceIconWidget().paddingLeft(12),
                  ],
                ).paddingOnly(left: 16),
                16.height,
                Marquee(
                  directionMarguee: DirectionMarguee.oneDirection,
                  child: Text(widget.serviceData.name.validate(), style: boldTextStyle()),
                ).paddingSymmetric(horizontal: 16),
                16.height,
                Marquee(
                  directionMarguee: DirectionMarguee.oneDirection,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.serviceData.discount != 0)
                        PriceWidget(
                          price: discountedAmount,
                          isHourlyService: widget.serviceData.isHourlyService,
                          color: primaryColor,
                          hourlyTextColor: primaryColor,
                          size: 16,
                          isFreeService: widget.serviceData.type.validate() == SERVICE_TYPE_FREE,
                        ),
                      if (widget.serviceData.discount != 0) 8.width,
                      PriceWidget(
                        price: widget.serviceData.price.validate(),
                        isLineThroughEnabled: widget.serviceData.discount != 0 ? true : false,
                        isHourlyService: widget.serviceData.isHourlyService,
                        color: widget.serviceData.discount != 0 ? textSecondaryColorGlobal : primaryColor,
                        hourlyTextColor: widget.serviceData.discount != 0 ? textSecondaryColorGlobal : primaryColor,
                        size: widget.serviceData.discount != 0 ? 14 : 16,
                        isFreeService: widget.serviceData.type.validate() == SERVICE_TYPE_FREE,
                      ),
                    ],
                  ),
                ).paddingSymmetric(horizontal: 16),
                Divider(color: context.dividerColor, height: 20),
                Row(
                  children: [
                    ImageBorder(src: widget.serviceData.providerImage.validate(), height: 30),
                    8.width,
                    if (widget.serviceData.providerName.validate().isNotEmpty)
                      Text(
                        widget.serviceData.providerName.validate(),
                        style: secondaryTextStyle(size: 12, color: appStore.isDarkMode ? Colors.white : appTextSecondaryColor),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ).expand()
                  ],
                ).onTap(() async {
                  if (widget.serviceData.providerId != appStore.userId.validate()) {
                    await ProviderInfoScreen(providerId: widget.serviceData.providerId.validate()).launch(context);
                    setStatusBarColor(Colors.transparent);
                  }
                }).paddingSymmetric(horizontal: 16),
                16.height,
              ],
            ),
          ],
        ),
      ),
    );
  }

  num get finalDiscountAmount => widget.serviceData.discount != 0 ? ((widget.serviceData.price.validate() / 100) * widget.serviceData.discount.validate()).toStringAsFixed(appConfigurationStore.priceDecimalPoint).toDouble() : 0;

  num get discountedAmount => widget.serviceData.price.validate() - finalDiscountAmount;
}
