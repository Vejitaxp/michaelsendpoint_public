# Conditional Access best practices

Parameter JSON Files for Conditional Access best practices based on the Microsoft recommendations.

You can import all Policies with the Scripts in this [Repository](https://github.com/Vejitaxp/michaelsendpoint_public/tree/beb9620701e4dc83fe0520f06e2969d4598c751f/Entra/Scripts).

1. Copy the JSOn Files in a Folder called "Conditional Access".
2. Copy the Scripts in the Parent Folder.
3. Run the following Scripts to create the needed prerequisites:
  -  [Create_Authentication_Strengh.ps1](https://github.com/Vejitaxp/michaelsendpoint_public/blob/20180b8da5455e50ba7dce5bac032712e876ee09/Entra/Scripts/Create_Authentication_Strengh.ps1)
  -  [Create_Named_Location.ps1](https://github.com/Vejitaxp/michaelsendpoint_public/blob/20180b8da5455e50ba7dce5bac032712e876ee09/Entra/Scripts/Create_Named_Location.ps1)
  -  [Create_Service_Principal.ps1](https://github.com/Vejitaxp/michaelsendpoint_public/blob/20180b8da5455e50ba7dce5bac032712e876ee09/Entra/Scripts/Create_Service_Principal.ps1)
4. Now run the [Import_Conditional_Access_Policies.ps1](https://github.com/Vejitaxp/michaelsendpoint_public/blob/20180b8da5455e50ba7dce5bac032712e876ee09/Entra/Scripts/Import_Conditional_Access_Policies.ps1) Script.

> [!NOTE]
> Please be aware that without an Entra P2 License you will get an error creating the two policies with Sign-In Risk, because you don`t have the license for that.
