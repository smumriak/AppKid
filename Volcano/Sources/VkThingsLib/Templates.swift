//
//  Templates.swift
//  Volcano
//
//  Created by Serhii Mumriak on 13.06.2023
//

public enum Templates {
    public static let outputStructureExtension =
        """
        extension <NAME>: VulkanOutStructure {
            public static let type: VkStructureType = <TYPE>
        }
        """

    public static let inputStructureExtension =
        """
        extension <NAME>: VulkanInStructure {
            public static let type: VkStructureType = <TYPE>
        }
        """

    public static let vulkanCEnumsLicense =
        """
        //
        //  VulkanEnums.h
        //  Volcano
        //
        //  Created by Serhii Mumriak on 17.08.2020.
        //
        """

    public static let vulkanCOptionSetsLicense =
        """
        //
        //  VulkanOptionSets.h
        //  Volcano
        //
        //  Created by Serhii Mumriak on 17.08.2020.
        //
        """

    public static let vulkanSwiftStructuresLicense =
        """
        //
        //  VulkanStructureConformance.swift
        //  Volcano
        //
        //  Created by Serhii Mumriak on 28.01.2021.
        //
        """

    public static let vulkanSwiftEnumsLicense =
        """
        //
        //  VulkanEnums.swift
        //  Volcano
        //
        //  Created by Serhii Mumriak on 28.01.2021.
        //
        """

    public static let vulkanSwiftOptionSetsLicense =
        """
        //
        //  VulkanOptionSets.swift
        //  Volcano
        //
        //  Created by Serhii Mumriak on 28.01.2021.
        //
        """

    public static let vulkanSwiftExtensionsLicense =
        """
        //
        //  VulkanExtensionsNames.swift
        //  Volcano
        //
        //  Created by Serhii Mumriak on 20.07.2021.
        //
        """
}
