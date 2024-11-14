// Copyright 2021 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import 'constants.dart'; // 상수 정의 파일 (색상, 텍스트 스타일 등)
import 'home.dart'; // 메인 화면을 구성하는 홈 위젯

// 앱 실행
void main() async {
  runApp(const App());
}

class App extends StatefulWidget { // StatefulWidget: 상태 변경 위젯 <-> StatelessWidget
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

// 앱의 상태를 관리하는 class
class _AppState extends State<App> {
  bool useMaterial3 = true; // Material3 디자인 사용 여부
  ThemeMode themeMode = ThemeMode.system; // 테마 모드: 시스템 테마, 밝은 테마, 어두운 테마
  ColorSeed colorSelected = ColorSeed.baseColor;  // 색상 시드 (기본 색상)  constants.dart에서 가져옴
  ColorImageProvider imageSelected = ColorImageProvider.leaves; // 이미지 기반 테마 선택 constants.dart에서 가져옴
  ColorScheme? imageColorScheme = const ColorScheme.light(); // 이미지에서 추출한 색상 테마
  ColorSelectionMethod colorSelectionMethod = ColorSelectionMethod.colorSeed; // 색상 선택 constants.dart에서 가져옴

  // 밝은 모드 사용 여부 메소드
  bool get useLightMode => switch (themeMode) {
    ThemeMode.system => // 시스템 테마
    View.of(context).platformDispatcher.platformBrightness ==
        Brightness.light,
    ThemeMode.light => true,  // 밝은 테마
    ThemeMode.dark => false // 어두운 테마
  };

  // 밝기 모드 변경 처리
  void handleBrightnessChange(bool useLightMode) {
    setState(() {
      themeMode = useLightMode ? ThemeMode.light : ThemeMode.dark;  // 밝기 모드 설정
    });
  }

  // Material 디자인 버전 변경 처리
  void handleMaterialVersionChange() {
    setState(() {
      useMaterial3 = !useMaterial3; // 디자인 2와 3을 번갈아 사용
    });
  }

  // 색상 시드 선택
  void handleColorSelect(int value) {
    setState(() {
      colorSelectionMethod = ColorSelectionMethod.colorSeed;  // 색상 시드 방식으로 설정
      colorSelected = ColorSeed.values[value];  // 색상 시드 값 변경
    });
  }

  // 이미지 선택에 따른 색상 테마 설정 함수
  void handleImageSelect(int value) {
    final String url = ColorImageProvider.values[value].url;  // 선택한 이미지 URL 가져옴
    ColorScheme.fromImageProvider(provider: NetworkImage(url))
        .then((newScheme) { // 이미지로부터 색상 테마 생성
      setState(() {
        colorSelectionMethod = ColorSelectionMethod.image;  // 이미지 기반 색상 설정
        imageSelected = ColorImageProvider.values[value]; // 선택한 이미지 저장
        imageColorScheme = newScheme; // 새로 생성된 색상 테마 적용
      });
    });
  }

  // MaterialApp을 빌드하여 화면에 랜더링하는 함수
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,  // 디버그 배너 숨기기
      title: 'Material 3',  // 앱 제목 설정
      themeMode: themeMode, // 현재 테마 모드 적용
      theme: ThemeData(
        colorSchemeSeed: colorSelectionMethod == ColorSelectionMethod.colorSeed
            ? colorSelected.color // 색상 시드를 기반으로 색상 테마 설정
            : null,
        colorScheme: colorSelectionMethod == ColorSelectionMethod.image
            ? imageColorScheme  // 이미지 기반 색상 테마 설정
            : null,
        useMaterial3: useMaterial3, // Material3 적용 여부
        brightness: Brightness.light, // 기본 밝기 모드 설정
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: colorSelectionMethod == ColorSelectionMethod.colorSeed
            ? colorSelected.color
            : imageColorScheme!.primary,  // 다크모드용 색상 테마 설정
        useMaterial3: useMaterial3,
        brightness: Brightness.dark,  // 어두운 테마 모드
      ),
      home: Home( // home widget
        useLightMode: useLightMode, // 현재 밝기 모드
        useMaterial3: useMaterial3, // Material3 적용 여부 전달
        colorSelected: colorSelected, // 선택된 색상 시드 전달
        imageSelected: imageSelected, // 선택된 이미지 전달
        handleBrightnessChange: handleBrightnessChange, // 밝기 변경 함수 전달
        handleMaterialVersionChange: handleMaterialVersionChange, // Material 버전 변경 함수
        handleColorSelect: handleColorSelect, // 색상 시드 선택 함수 전달
        handleImageSelect: handleImageSelect, // 이미지 선택 함수 전달
        colorSelectionMethod: colorSelectionMethod, // 색상 선택 방식 전달
      ),
    );
  }
}

