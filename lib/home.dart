// Copyright 2021 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import 'color_palettes_screen.dart';
import 'component_screen.dart';
import 'constants.dart';
import 'elevation_screen.dart';
import 'typography_screen.dart';

class Home extends StatefulWidget { // StatefulWidget: 상태 변경 위젯 <-> StatelessWidget
  const Home({
    super.key, // 생성자
    // 매개변수
    required this.useLightMode,
    required this.useMaterial3,
    required this.colorSelected,
    required this.handleBrightnessChange,
    required this.handleMaterialVersionChange,
    required this.handleColorSelect,
    required this.handleImageSelect,
    required this.colorSelectionMethod,
    required this.imageSelected,
  });
  // UI 동작 제어 데이터 변수(전달 받은 파리미터)
  final bool useLightMode;  // 밝은 모드 or 어두운 모드
  final bool useMaterial3;  // Material3 or Material2
  final ColorSeed colorSelected;  // 선택한 색상 시드
  final ColorImageProvider imageSelected; // 이미지 기반 색상 시드가 선택된 경우 해당 이미지의 색상 시드
  final ColorSelectionMethod colorSelectionMethod;  // 색상 선택 방법(색상시드 or 이미지)

  // callback function (사용자가 설정을 변경할 때 호출)
  final void Function(bool useLightMode) handleBrightnessChange;  // 화면 밝기 변경
  final void Function() handleMaterialVersionChange;  // Material3 디자인 변경
  final void Function(int value) handleColorSelect; // 색상 시드 선택
  final void Function(int value) handleImageSelect; // 이미지 기반 색상 선택

  @override
  State<Home> createState() => _HomeState();  // 상태 객체를 생성하는 메소드
}

// Home 위젯 상태 관리 클래스
class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();  // ScaffoldState 위젯 상태 참조 전역 키
  late final AnimationController controller;  // 애니메이션 관리
  late final CurvedAnimation railAnimation; // 곡선 애니메이션 관리
  bool controllerInitialized = false; // 애니메이션 초기화 관리
  bool showMediumSizeLayout = false;  // 중간 크기 레이아웃 표시 여부
  bool showLargeSizeLayout = false; // 큰 크기 레이아웃 표시 여부

  int screenIndex = ScreenSelected.component.value; // 현재 화면에 표시할 인덱스 저장 변수

  @override
  initState() {
    super.initState();
    controller = AnimationController( // 애니메이션의 지속 시간은 전환 길이에 따라 설정
      duration: Duration(milliseconds: transitionLength.toInt() * 2),
      value: 0,
      vsync: this,
    );
    railAnimation = CurvedAnimation(  // 애니메이션에 곡선 구간 설정(절반 이후에 애니메이션 작동)
      parent: controller,
      curve: const Interval(0.5, 1.0),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final double width = MediaQuery.of(context).size.width; // 화면 너비
    final AnimationStatus status = controller.status; // 애니메이션 상태

    // 화면 너비에 따른 레이아웃 모드 설정(애니메이션 방향 결정)
    if (width > mediumWidthBreakpoint) {
      if (width > largeWidthBreakpoint) {
        showMediumSizeLayout = false;
        showLargeSizeLayout = true;
      } else {
        showMediumSizeLayout = true;
        showLargeSizeLayout = false;
      }
      if (status != AnimationStatus.forward &&
          status != AnimationStatus.completed) {
        controller.forward();
      }
    } else {
      showMediumSizeLayout = false;
      showLargeSizeLayout = false;
      if (status != AnimationStatus.reverse &&
          status != AnimationStatus.dismissed) {
        controller.reverse();
      }
    }
    if (!controllerInitialized) { // 초기화된 적이 없으면, 현재 화면 크기에 따라 애니메이션 값 설정
      controllerInitialized = true;
      controller.value = width > mediumWidthBreakpoint ? 1 : 0;
    }
  }

  // 화면 전환시 호출
  void handleScreenChanged(int screenSelected) {
    setState(() {
      screenIndex = screenSelected; // 화면의 인덱스 갱신
    });
  }

  // 선택된 화면 유형에 따라 다른 위젯을 반환하는 함수
  Widget createScreenFor(
      ScreenSelected screenSelected,
      bool showNavBarExample,
      ) =>
      switch (screenSelected) {
        ScreenSelected.component => Expanded(
          child: OneTwoTransition(
            animation: railAnimation,
            one: FirstComponentList(
                showNavBottomBar: showNavBarExample,
                scaffoldKey: scaffoldKey,
                showSecondList: showMediumSizeLayout || showLargeSizeLayout),
            two: SecondComponentList(
              scaffoldKey: scaffoldKey,
            ),
          ),
        ),
        ScreenSelected.color => const ColorPalettesScreen(),
        ScreenSelected.typography => const TypographyScreen(),
        ScreenSelected.elevation => const ElevationScreen()
      };

  // AppBar 생성 함수
  PreferredSizeWidget createAppBar() {
    return AppBar(
      title: widget.useMaterial3
          ? const Text('Material 3')
          : const Text('Material 2'),
      actions: !showMediumSizeLayout && !showLargeSizeLayout
          ? [
        _BrightnessButton(
          handleBrightnessChange: widget.handleBrightnessChange,
        ),
        _Material3Button(
          handleMaterialVersionChange: widget.handleMaterialVersionChange,
        ),
        _ColorSeedButton(
          handleColorSelect: widget.handleColorSelect,
          colorSelected: widget.colorSelected,
          colorSelectionMethod: widget.colorSelectionMethod,
        ),
        _ColorImageButton(
          handleImageSelect: widget.handleImageSelect,
          imageSelected: widget.imageSelected,
          colorSelectionMethod: widget.colorSelectionMethod,
        )
      ]
          : [Container()],
    );
  }

  // 큰 화면 레이아웃에서 사용할 추가 버튼 그룹
  Widget _trailingActions() => Column(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      Flexible(
        child: _BrightnessButton(
          handleBrightnessChange: widget.handleBrightnessChange,
          showTooltipBelow: false,
        ),
      ),
      Flexible(
        child: _Material3Button(
          handleMaterialVersionChange: widget.handleMaterialVersionChange,
          showTooltipBelow: false,
        ),
      ),
      Flexible(
        child: _ColorSeedButton(
          handleColorSelect: widget.handleColorSelect,
          colorSelected: widget.colorSelected,
          colorSelectionMethod: widget.colorSelectionMethod,
        ),
      ),
      Flexible(
        child: _ColorImageButton(
          handleImageSelect: widget.handleImageSelect,
          imageSelected: widget.imageSelected,
          colorSelectionMethod: widget.colorSelectionMethod,
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return NavigationTransition(
          scaffoldKey: scaffoldKey,
          animationController: controller,
          railAnimation: railAnimation,
          appBar: createAppBar(),
          body: createScreenFor(
              ScreenSelected.values[screenIndex], controller.value == 1),
          navigationRail: NavigationRail(
            extended: showLargeSizeLayout,
            destinations: navRailDestinations,
            selectedIndex: screenIndex,
            onDestinationSelected: (index) {
              setState(() {
                screenIndex = index;
                handleScreenChanged(screenIndex);
              });
            },
            trailing: Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: showLargeSizeLayout
                    ? _ExpandedTrailingActions(
                  useLightMode: widget.useLightMode,
                  handleBrightnessChange: widget.handleBrightnessChange,
                  useMaterial3: widget.useMaterial3,
                  handleMaterialVersionChange:
                  widget.handleMaterialVersionChange,
                  handleImageSelect: widget.handleImageSelect,
                  handleColorSelect: widget.handleColorSelect,
                  colorSelectionMethod: widget.colorSelectionMethod,
                  imageSelected: widget.imageSelected,
                  colorSelected: widget.colorSelected,
                )
                    : _trailingActions(),
              ),
            ),
          ),
          navigationBar: NavigationBars(
            onSelectItem: (index) {
              setState(() {
                screenIndex = index;
                handleScreenChanged(screenIndex);
              });
            },
            selectedIndex: screenIndex,
            isExampleBar: false,
          ),
        );
      },
    );
  }
}

// 밝기 모드 버튼 클래스
class _BrightnessButton extends StatelessWidget {
  const _BrightnessButton({
    required this.handleBrightnessChange,
    this.showTooltipBelow = true,
  });

  final Function handleBrightnessChange;  // 밝기 변경을 처리하는 콜백함수
  final bool showTooltipBelow;  // 툴팁이 아래에 표시할 것인지 여부

  @override
  Widget build(BuildContext context) {
    final isBright = Theme.of(context).brightness == Brightness.light;  // 현재 디바이스의 밝기 모드 체크
    return Tooltip(
      preferBelow: showTooltipBelow,  // 툴팁 버튼을 아래에 표시할 것인지 여부
      message: 'Toggle brightness', // 툴팁 메세지
      child: IconButton(
        icon: isBright  // 밝은 모드인가?
            ? const Icon(Icons.dark_mode_outlined)  // 참이면 어두운 모드 아이콘
            : const Icon(Icons.light_mode_outlined), // 거짓이면 밝은 모드 아이콘
        onPressed: () => handleBrightnessChange(!isBright), // 버튼 클릭 시 밝기 모드 전환
      ),
    );
  }
}

// Material3 전환 버튼 클래스
class _Material3Button extends StatelessWidget {
  const _Material3Button({
    required this.handleMaterialVersionChange,
    this.showTooltipBelow = true,
  });

  final void Function() handleMaterialVersionChange;  // Material 버전 변경을 처리하는 콜백 함수
  final bool showTooltipBelow;  // 툴팁이 버튼 아래에 표시할건지 여부

  @override
  Widget build(BuildContext context) {
    final useMaterial3 = Theme.of(context).useMaterial3;  // 현재 디자인이 Material 디자인인지 확인
    return Tooltip(
      preferBelow: showTooltipBelow,  // 툴팁을 버튼 아래에 표시할지 여부
      message: 'Switch to Material ${useMaterial3 ? 2 : 3}',  // 툴팁 메세지
      child: IconButton(
        icon: useMaterial3
            ? const Icon(Icons.filter_2)
            : const Icon(Icons.filter_3),
        onPressed: handleMaterialVersionChange,
      ),
    );
  }
}

// 색상 시드 선택 버튼
class _ColorSeedButton extends StatelessWidget {
  const _ColorSeedButton({
    required this.handleColorSelect,
    required this.colorSelected,
    required this.colorSelectionMethod,
  });

  final void Function(int) handleColorSelect; // 색상 선택을 처리하는 함수
  final ColorSeed colorSelected;  // 현재 선택된 색상
  final ColorSelectionMethod colorSelectionMethod;  // 색상 선택 방법(색상 시드 or 이미지)

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      icon: const Icon(
        Icons.palette_outlined, // 팔레트 아이콘
      ),
      tooltip: 'Select a seed color', // 툴팁 메세지
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // 팝업 메뉴 모서리 둥글기 10
      itemBuilder: (context) {
        return List.generate(ColorSeed.values.length, (index) {
          ColorSeed currentColor = ColorSeed.values[index]; // 각 색상 시드 가져옴

          return PopupMenuItem(
            value: index, // 선택된 값의 인덱스 반환
            enabled: currentColor != colorSelected ||
                colorSelectionMethod != ColorSelectionMethod.colorSeed, // 선택된 색상 시드 != 현재 선택된 색상 이거나 선택 방법이 색상 시드가 아닐때 항목 활성화
            child: Wrap(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Icon(
                    currentColor == colorSelected &&
                        colorSelectionMethod != ColorSelectionMethod.image
                        ? Icons.color_lens  // 선택된 색상 시드일 경우 색상 렌즈 아이콘
                        : Icons.color_lens_outlined,  // 그렇지 않으면 색상 렌즈 아웃라인 아이콘
                    color: currentColor.color,  // 색상 시드의 색상으로 아이콘 색상 설정
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text(currentColor.label),  // 색상 시드의 라벨 표시
                ),
              ],
            ),
          );
        });
      },
      onSelected: handleColorSelect,  // 색상 선택 시 호출되는 콜백 함수
    );
  }
}

// 이미지에서 색상 추출하는 버튼 클래스
class _ColorImageButton extends StatelessWidget {
  const _ColorImageButton({
    required this.handleImageSelect,
    required this.imageSelected,
    required this.colorSelectionMethod,
  });

  final void Function(int) handleImageSelect; // 이미지 선택을 처리하는 함수
  final ColorImageProvider imageSelected; // 현재 선택된 이미지 제공자
  final ColorSelectionMethod colorSelectionMethod;  // 색상 선택 방법 (색상 시드 또는 이미지)

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      icon: const Icon(
        Icons.image_outlined, // 이미지 아이콘
      ),
      tooltip: 'Select a color extraction image', // 버튼에 대한 툴팁
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // 팝업 메뉴의 모서리를 둥글게 만듦
      itemBuilder: (context) {
        return List.generate(ColorImageProvider.values.length, (index) {
          final currentImageProvider = ColorImageProvider.values[index];  // 각 이미지 제공자 항목을 가져옴

          return PopupMenuItem(
            value: index, // 선택된 값의 인덱스를 반환
            enabled: currentImageProvider != imageSelected ||
                colorSelectionMethod != ColorSelectionMethod.image, // 선택된 이미지 제공자가 현재 선택된 이미지 제공자와 다르거나, 색상 선택 방법이 이미지가 아닐 때만 항목을 활성화
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 48),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image(
                          image: NetworkImage(currentImageProvider.url),  // 이미지 제공자의 URL로 이미지 표시
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text(currentImageProvider.label),  // 이미지 제공자의 라벨 표시
                ),
              ],
            ),
          );
        });
      },
      onSelected: handleImageSelect,  // 이미지 선택 시 호출되는 콜백 함수
    );
  }
}

class _ExpandedTrailingActions extends StatelessWidget {
  const _ExpandedTrailingActions({
    required this.useLightMode,
    required this.handleBrightnessChange,
    required this.useMaterial3,
    required this.handleMaterialVersionChange,
    required this.handleColorSelect,
    required this.handleImageSelect,
    required this.imageSelected,
    required this.colorSelected,
    required this.colorSelectionMethod,
  });

  final void Function(bool) handleBrightnessChange;
  final void Function() handleMaterialVersionChange;
  final void Function(int) handleImageSelect;
  final void Function(int) handleColorSelect;

  final bool useLightMode;
  final bool useMaterial3;

  final ColorImageProvider imageSelected;
  final ColorSeed colorSelected;
  final ColorSelectionMethod colorSelectionMethod;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final trailingActionsBody = Container(
      constraints: const BoxConstraints.tightFor(width: 250),
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text('Brightness'),
              Expanded(child: Container()),
              Switch(
                  value: useLightMode,
                  onChanged: (value) {
                    handleBrightnessChange(value);
                  })
            ],
          ),
          Row(
            children: [
              useMaterial3
                  ? const Text('Material 3')
                  : const Text('Material 2'),
              Expanded(child: Container()),
              Switch(
                  value: useMaterial3,
                  onChanged: (_) {
                    handleMaterialVersionChange();
                  })
            ],
          ),
          const Divider(),
          _ExpandedColorSeedAction(
            handleColorSelect: handleColorSelect,
            colorSelected: colorSelected,
            colorSelectionMethod: colorSelectionMethod,
          ),
          const Divider(),
          _ExpandedImageColorAction(
            handleImageSelect: handleImageSelect,
            imageSelected: imageSelected,
            colorSelectionMethod: colorSelectionMethod,
          ),
        ],
      ),
    );
    return screenHeight > 740
        ? trailingActionsBody
        : SingleChildScrollView(child: trailingActionsBody);
  }
}

class _ExpandedColorSeedAction extends StatelessWidget {
  const _ExpandedColorSeedAction({
    required this.handleColorSelect,
    required this.colorSelected,
    required this.colorSelectionMethod,
  });

  final void Function(int) handleColorSelect;
  final ColorSeed colorSelected;
  final ColorSelectionMethod colorSelectionMethod;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 200.0),
      child: GridView.count(
        crossAxisCount: 3,
        children: List.generate(
          ColorSeed.values.length,
              (i) => IconButton(
            icon: const Icon(Icons.radio_button_unchecked),
            color: ColorSeed.values[i].color,
            isSelected: colorSelected.color == ColorSeed.values[i].color &&
                colorSelectionMethod == ColorSelectionMethod.colorSeed,
            selectedIcon: const Icon(Icons.circle),
            onPressed: () {
              handleColorSelect(i);
            },
            tooltip: ColorSeed.values[i].label,
          ),
        ),
      ),
    );
  }
}

class _ExpandedImageColorAction extends StatelessWidget {
  const _ExpandedImageColorAction({
    required this.handleImageSelect,
    required this.imageSelected,
    required this.colorSelectionMethod,
  });

  final void Function(int) handleImageSelect;
  final ColorImageProvider imageSelected;
  final ColorSelectionMethod colorSelectionMethod;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 150.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: GridView.count(
          crossAxisCount: 3,
          children: List.generate(
            ColorImageProvider.values.length,
                (i) => Tooltip(
              message: ColorImageProvider.values[i].name,
              child: InkWell(
                borderRadius: BorderRadius.circular(4.0),
                onTap: () => handleImageSelect(i),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Material(
                    borderRadius: BorderRadius.circular(4.0),
                    elevation: imageSelected == ColorImageProvider.values[i] &&
                        colorSelectionMethod == ColorSelectionMethod.image
                        ? 3
                        : 0,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4.0),
                        child: Image(
                          image: NetworkImage(ColorImageProvider.values[i].url),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NavigationTransition extends StatefulWidget {
  const NavigationTransition(
      {super.key,
        required this.scaffoldKey,
        required this.animationController,
        required this.railAnimation,
        required this.navigationRail,
        required this.navigationBar,
        required this.appBar,
        required this.body});

  final GlobalKey<ScaffoldState> scaffoldKey;
  final AnimationController animationController;
  final CurvedAnimation railAnimation;
  final Widget navigationRail;
  final Widget navigationBar;
  final PreferredSizeWidget appBar;
  final Widget body;

  @override
  State<NavigationTransition> createState() => _NavigationTransitionState();
}

class _NavigationTransitionState extends State<NavigationTransition> {
  late final AnimationController controller;
  late final CurvedAnimation railAnimation;
  late final ReverseAnimation barAnimation;
  bool controllerInitialized = false;
  bool showDivider = false;

  @override
  void initState() {
    super.initState();

    controller = widget.animationController;
    railAnimation = widget.railAnimation;

    barAnimation = ReverseAnimation(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.0, 0.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      key: widget.scaffoldKey,
      appBar: widget.appBar,
      body: Row(
        children: <Widget>[
          RailTransition(
            animation: railAnimation,
            backgroundColor: colorScheme.surface,
            child: widget.navigationRail,
          ),
          widget.body,
        ],
      ),
      bottomNavigationBar: BarTransition(
        animation: barAnimation,
        backgroundColor: colorScheme.surface,
        child: widget.navigationBar,
      ),
      endDrawer: const NavigationDrawerSection(),
    );
  }
}

final List<NavigationRailDestination> navRailDestinations = appBarDestinations
    .map(
      (destination) => NavigationRailDestination(
    icon: Tooltip(
      message: destination.label,
      child: destination.icon,
    ),
    selectedIcon: Tooltip(
      message: destination.label,
      child: destination.selectedIcon,
    ),
    label: Text(destination.label),
  ),
)
    .toList();

class SizeAnimation extends CurvedAnimation {
  SizeAnimation(Animation<double> parent)
      : super(
    parent: parent,
    curve: const Interval(
      0.2,
      0.8,
      curve: Curves.easeInOutCubicEmphasized,
    ),
    reverseCurve: Interval(
      0,
      0.2,
      curve: Curves.easeInOutCubicEmphasized.flipped,
    ),
  );
}

class OffsetAnimation extends CurvedAnimation {
  OffsetAnimation(Animation<double> parent)
      : super(
    parent: parent,
    curve: const Interval(
      0.4,
      1.0,
      curve: Curves.easeInOutCubicEmphasized,
    ),
    reverseCurve: Interval(
      0,
      0.2,
      curve: Curves.easeInOutCubicEmphasized.flipped,
    ),
  );
}

class RailTransition extends StatefulWidget {
  const RailTransition(
      {super.key,
        required this.animation,
        required this.backgroundColor,
        required this.child});

  final Animation<double> animation;
  final Widget child;
  final Color backgroundColor;

  @override
  State<RailTransition> createState() => _RailTransition();
}

class _RailTransition extends State<RailTransition> {
  late Animation<Offset> offsetAnimation;
  late Animation<double> widthAnimation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // The animations are only rebuilt by this method when the text
    // direction changes because this widget only depends on Directionality.
    final bool ltr = Directionality.of(context) == TextDirection.ltr;

    widthAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(SizeAnimation(widget.animation));

    offsetAnimation = Tween<Offset>(
      begin: ltr ? const Offset(-1, 0) : const Offset(1, 0),
      end: Offset.zero,
    ).animate(OffsetAnimation(widget.animation));
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: DecoratedBox(
        decoration: BoxDecoration(color: widget.backgroundColor),
        child: Align(
          alignment: Alignment.topLeft,
          widthFactor: widthAnimation.value,
          child: FractionalTranslation(
            translation: offsetAnimation.value,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class BarTransition extends StatefulWidget {
  const BarTransition(
      {super.key,
        required this.animation,
        required this.backgroundColor,
        required this.child});

  final Animation<double> animation;
  final Color backgroundColor;
  final Widget child;

  @override
  State<BarTransition> createState() => _BarTransition();
}

class _BarTransition extends State<BarTransition> {
  late final Animation<Offset> offsetAnimation;
  late final Animation<double> heightAnimation;

  @override
  void initState() {
    super.initState();

    offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(OffsetAnimation(widget.animation));

    heightAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(SizeAnimation(widget.animation));
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: DecoratedBox(
        decoration: BoxDecoration(color: widget.backgroundColor),
        child: Align(
          alignment: Alignment.topLeft,
          heightFactor: heightAnimation.value,
          child: FractionalTranslation(
            translation: offsetAnimation.value,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class OneTwoTransition extends StatefulWidget {
  const OneTwoTransition({
    super.key,
    required this.animation,
    required this.one,
    required this.two,
  });

  final Animation<double> animation;
  final Widget one;
  final Widget two;

  @override
  State<OneTwoTransition> createState() => _OneTwoTransitionState();
}

class _OneTwoTransitionState extends State<OneTwoTransition> {
  late final Animation<Offset> offsetAnimation;
  late final Animation<double> widthAnimation;

  @override
  void initState() {
    super.initState();

    offsetAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(OffsetAnimation(widget.animation));

    widthAnimation = Tween<double>(
      begin: 0,
      end: mediumWidthBreakpoint,
    ).animate(SizeAnimation(widget.animation));
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Flexible(
          flex: mediumWidthBreakpoint.toInt(),
          child: widget.one,
        ),
        if (widthAnimation.value.toInt() > 0) ...[
          Flexible(
            flex: widthAnimation.value.toInt(),
            child: FractionalTranslation(
              translation: offsetAnimation.value,
              child: widget.two,
            ),
          )
        ],
      ],
    );
  }
}