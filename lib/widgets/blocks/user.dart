import 'package:anxeb_flutter/middleware/utils.dart';
import 'package:anxeb_flutter/widgets/buttons/image.dart';
import 'package:flutter/material.dart';

class UserBlock extends StatelessWidget {
  final ImageProvider? background;
  final Color? color;
  final bool safeArea;
  final bool includeImageProfile;
  final EdgeInsets? padding;
  final String? imageUrl;
  final String? authToken;
  final String? userName;
  final String? userTitle;
  final VoidCallback? onTap;

  const UserBlock({
    super.key,
    this.background,
    this.color,
    this.safeArea = false,
    this.includeImageProfile = true,
    this.padding,
    this.imageUrl,
    this.authToken,
    this.userName,
    this.userTitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final mainColor = color ?? Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        boxShadow: const [
          BoxShadow(
            offset: Offset(0, 8),
            blurRadius: 8,
            spreadRadius: -5,
            color: Color(0x44000000),
          ),
        ],
        image: background != null
            ? DecorationImage(
                fit: BoxFit.cover,
                image: background!,
              )
            : null,
      ),
      child: SafeArea(
        top: safeArea,
        bottom: false,
        child: Container(
          padding: padding ??
              Utils.convert.fromInsetToFraction(
                const EdgeInsets.only(left: 0.03, top: 0.03, bottom: 0.03),
                size,
              ),
          child: Row(
            children: [
              if (includeImageProfile)
                Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: ImageButton(
                    height: 90,
                    width: 90,
                    imageUrl: imageUrl,
                    innerPadding: const EdgeInsets.all(5),
                    headers: authToken != null
                        ? {'Authorization': 'Bearer $authToken'}
                        : null,
                    outerBorderColor: mainColor,
                    failedIcon: Icons.account_circle,
                    failedIconColor: mainColor.withAlpha(50),
                    outerThickness: 3,
                    onTap: onTap != null ? () async => onTap!() : null,
                  ),
                ),
              // 🔹 Datos de usuario
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🔸 Nombre del usuario
                      Container(
                        padding: const EdgeInsets.only(
                            left: 8.0, right: 10.0, bottom: 6.0, top: 12),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: mainColor,
                              width: 1.0,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                userName ?? '',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: mainColor,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // 🔸 Título o rol
                      Container(
                        padding: const EdgeInsets.only(
                            left: 8.0, right: 10.0, bottom: 15.0, top: 7),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                (userTitle ?? '').toUpperCase(),
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: mainColor,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  letterSpacing: 0.1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
