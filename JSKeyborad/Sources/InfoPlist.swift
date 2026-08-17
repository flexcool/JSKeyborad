import Foundation

struct InfoPlist {
    static let mainApp: [String: Any] = [
        "CFBundleDevelopmentRegion": "zh-Hans",
        "CFBundleDisplayName": "JSKeyborad",
        "CFBundleExecutable": "$(EXECUTABLE_NAME)",
        "CFBundleIdentifier": "$(PRODUCT_BUNDLE_IDENTIFIER)",
        "CFBundleInfoDictionaryVersion": "6.0",
        "CFBundleName": "$(PRODUCT_NAME)",
        "CFBundlePackageType": "$(PRODUCT_BUNDLE_PACKAGE_TYPE)",
        "CFBundleShortVersionString": "1.0.0",
        "CFBundleVersion": "1",
        "LSRequiresIPhoneOS": true,
        "UIApplicationSceneManifest": [
            "UIApplicationSupportsMultipleScenes": false,
            "UISceneConfigurations": [
                "UIWindowSceneSessionRoleApplication": [
                    [
                        "UISceneConfigurationName": "Default Configuration",
                        "UISceneDelegateClassName": "$(PRODUCT_MODULE_NAME).SceneDelegate"
                    ]
                ]
            ]
        ],
        "UILaunchStoryboardName": "LaunchScreen",
        "UISupportedInterfaceOrientations": [
            "UIInterfaceOrientationPortrait",
            "UIInterfaceOrientationLandscapeLeft",
            "UIInterfaceOrientationLandscapeRight"
        ],
        "CFBundleURLTypes": [
            [
                "CFBundleURLName": "JSKeyborad",
                "CFBundleURLSchemes": ["jskeyborad"]
            ]
        ]
    ]
    
    static let keyboardExtension: [String: Any] = [
        "CFBundleDevelopmentRegion": "$(DEVELOPMENT_LANGUAGE)",
        "CFBundleDisplayName": "JSKeyborad",
        "CFBundleExecutable": "$(EXECUTABLE_NAME)",
        "CFBundleIdentifier": "$(PRODUCT_BUNDLE_IDENTIFIER)",
        "CFBundleInfoDictionaryVersion": "6.0",
        "CFBundleName": "$(PRODUCT_NAME)",
        "CFBundlePackageType": "$(PRODUCT_BUNDLE_PACKAGE_TYPE)",
        "CFBundleShortVersionString": "1.0.0",
        "CFBundleVersion": "1",
        "NSExtension": [
            "NSExtensionAttributes": [
                "IsASCIICapable": false,
                "PrefersRightToLeft": false,
                "PrimaryLanguage": "zh-Hans",
                "RequestsOpenAccess": false,
                "Weight": 100
            ],
            "NSExtensionPointIdentifier": "com.apple.keyboard-service",
            "NSExtensionPrincipalClass": "$(PRODUCT_MODULE_NAME).KeyboardViewController"
        ]
    ]
    
    static let widgetExtension: [String: Any] = [
        "CFBundleDevelopmentRegion": "$(DEVELOPMENT_LANGUAGE)",
        "CFBundleDisplayName": "JSKeyborad Widget",
        "CFBundleExecutable": "$(EXECUTABLE_NAME)",
        "CFBundleIdentifier": "$(PRODUCT_BUNDLE_IDENTIFIER)",
        "CFBundleInfoDictionaryVersion": "6.0",
        "CFBundleName": "$(PRODUCT_NAME)",
        "CFBundlePackageType": "$(PRODUCT_BUNDLE_PACKAGE_TYPE)",
        "CFBundleShortVersionString": "1.0.0",
        "CFBundleVersion": "1",
        "NSExtension": [
            "NSExtensionPointIdentifier": "com.apple.widgetkit-extension"
        ]
    ]
}
