import {BaseEntity,Column,Entity,Index,JoinColumn,JoinTable,ManyToMany,ManyToOne,OneToMany,OneToOne,PrimaryColumn,PrimaryGeneratedColumn,RelationId} from "typeorm";
import {time_entry} from "./time_entry";
import {workspace} from "./workspace";
import {project} from "./project";


@Entity("account" ,{schema:"app_public" } )
export class account {

    @Column("uuid",{ 
        nullable:false,
        primary:true,
        default: () => "uuid_generate_v1mc()",
        name:"id"
        })
    id:string;
        

    @Column("timestamp without time zone",{ 
        nullable:false,
        default: () => "now()",
        name:"created_at"
        })
    created_at:Date;
        

    @Column("timestamp without time zone",{ 
        nullable:false,
        default: () => "now()",
        name:"updated_at"
        })
    updated_at:Date;
        

    @Column("text",{ 
        nullable:true,
        name:"first_name"
        })
    first_name:string | null;
        

    @Column("text",{ 
        nullable:true,
        name:"last_name"
        })
    last_name:string | null;
        

    @Column("text",{ 
        nullable:true,
        name:"description"
        })
    description:string | null;
        

   
    @OneToMany(()=>time_entry, (time_entry: time_entry)=>time_entry.account,{ onDelete: 'SET NULL' , })
    timeEntrys:time_entry[];
    

   
    @ManyToMany(()=>workspace, (workspace: workspace)=>workspace.accounts,{  nullable:false, })
    @JoinTable({ name:'account_workspace_xref'})
    workspaces:workspace[];
    

   
    @ManyToMany(()=>project, (project: project)=>project.accounts,{  nullable:false, })
    @JoinTable({ name:'account_project_xref'})
    projects:project[];
    
}
