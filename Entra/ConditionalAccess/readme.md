# Conditional Access best practices

Parameter JSON Files for Conditional Access best practices based on the Microsoft and other recommendations.

You can import all Policies with the Scripts in this [Repository](https://github.com/Vejitaxp/michaelsendpoint_public/tree/beb9620701e4dc83fe0520f06e2969d4598c751f/Entra/Scripts).

1. Copy the JSOn Files in a Folder called "Conditional Access".
2. Copy the Scripts in the Parent Folder.
3. Run the following Scripts to create the needed prerequisites:
    -  [Create_Authentication_Strengh.ps1](https://github.com/Vejitaxp/michaelsendpoint_public/blob/20180b8da5455e50ba7dce5bac032712e876ee09/Entra/Scripts/Create_Authentication_Strengh.ps1)
    -  [Create_Named_Location.ps1](https://github.com/Vejitaxp/michaelsendpoint_public/blob/20180b8da5455e50ba7dce5bac032712e876ee09/Entra/Scripts/Create_Named_Location.ps1)
    -  [Create_Service_Principal.ps1](https://github.com/Vejitaxp/michaelsendpoint_public/blob/20180b8da5455e50ba7dce5bac032712e876ee09/Entra/Scripts/Create_Service_Principal.ps1)
4. Now run the [Import_Conditional_Access_Policies.ps1](https://github.com/Vejitaxp/michaelsendpoint_public/blob/20180b8da5455e50ba7dce5bac032712e876ee09/Entra/Scripts/Import_Conditional_Access_Policies.ps1) Script.

> [!IMPORTANT]
> Please be aware that without an Entra P2 License you will get an error creating the two policies with Sign-In Risk, because you don`t have the license for that.

> [!CAUTION]
> When you intend to add the policy [Global-BaseProtection-AllApps-AnyPlatform-BlockNonPersonas-CA016.json](https://github.com/Vejitaxp/michaelsendpoint_public/blob/15ff1a0744be29b38de9f355ee3d8d270e738151/Entra/ConditionalAccess/Global-BaseProtection-AllApps-AnyPlatform-BlockNonPersonas-CA016.json),
> please be aware that you should create two groups first.
> - The first group should include all of your hybrid users. This group could be a dynamic group.
> - The second group should include all cloud only accounts. This group should not be dynamic.
> 
> If you create the two groups before you import the policies, with the names "all_cloud_users" and "all_hybrid_users", the groups will be added to the exclutions automatically. 
> <br>
> The purpose of this policy is to block all newly created cloud users unless an administrator actively adds them to a group, either manually or through User Lifecycle Management.
> This way an attacker has no way of gaining access without an administrator knowing. All you need to do is audit additions to the cloud-only user group.
