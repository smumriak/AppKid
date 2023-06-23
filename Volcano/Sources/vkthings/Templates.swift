//
//  Templates.swift
//  Volcano
//
//  Created by Serhii Mumriak on 13.06.2023
//

enum Templates {
    static let outputStructureExtension =
        """
        extension <NAME>: VulkanOutStructure {
            public static let type: VkStructureType = <TYPE>
        }
        """

    static let inputStructureExtension =
        """
        extension <NAME>: VulkanInStructure {
            public static let type: VkStructureType = <TYPE>
        }
        """

    static let vulkanCEnumsLicense =
        """
        //
        //  VulkanEnums.h
        //  Volcano
        //
        //  Created by Serhii Mumriak on 17.08.2020.
        //
        """

    static let vulkanCOptionSetsLicense =
        """
        //
        //  VulkanOptionSets.h
        //  Volcano
        //
        //  Created by Serhii Mumriak on 17.08.2020.
        //
        """

    static let vulkanSwiftStructuresLicense =
        """
        //
        //  VulkanStructureConformance.swift
        //  Volcano
        //
        //  Created by Serhii Mumriak on 28.01.2021.
        //
        """

    static let vulkanSwiftEnumsLicense =
        """
        //
        //  VulkanEnums.swift
        //  Volcano
        //
        //  Created by Serhii Mumriak on 28.01.2021.
        //
        """

    static let vulkanSwiftOptionSetsLicense =
        """
        //
        //  VulkanOptionSets.swift
        //  Volcano
        //
        //  Created by Serhii Mumriak on 28.01.2021.
        //
        """

    static let vulkanSwiftExtensionsLicense =
        """
        //
        //  VulkanExtensionsNames.swift
        //  Volcano
        //
        //  Created by Serhii Mumriak on 20.07.2021.
        //
        """
}
