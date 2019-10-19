import {BaseEntity,Column,Entity,Index,JoinColumn,JoinTable,ManyToMany,ManyToOne,OneToMany,OneToOne,PrimaryColumn,PrimaryGeneratedColumn,RelationId} from "typeorm";
import {account} from "./account";
import {project} from "./project";
import {client} from "./client";
import {tag} from "./tag";


@Entity("time_entry" ,{schema:"app_public" } )
@Index("time_entry_account_id_fkey",["account",])
@Index("time_entry_client_id_fkey",["client",])
@Index("time_entry_project_id_fkey",["project",])
export class time_entry {

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
        name:"name"
        })
    name:string | null;
        

    @Column("text",{ 
        nullable:true,
        name:"description"
        })
    description:string | null;
        

    @Column("timestamp without time zone",{ 
        nullable:true,
        name:"started_at"
        })
    started_at:Date | null;
        

    @Column("timestamp without time zone",{ 
        nullable:true,
        name:"ended_at"
        })
    ended_at:Date | null;
        

   
    @ManyToOne(()=>account, (account: account)=>account.timeEntrys,{  nullable:false,onDelete: 'SET NULL', })
    @JoinColumn({ name:'account_id'})
    account:account | null;


   
    @ManyToOne(()=>project, (project: project)=>project.timeEntrys,{ onDelete: 'SET NULL', })
    @JoinColumn({ name:'project_id'})
    project:project | null;


   
    @ManyToOne(()=>client, (client: client)=>client.timeEntrys,{ onDelete: 'SET NULL', })
    @JoinColumn({ name:'client_id'})
    client:client | null;


   
    @ManyToMany(()=>tag, (tag: tag)=>tag.timeEntrys,{  nullable:false, })
    @JoinTable({ name:'time_entry_tag_xref'})
    tags:tag[];
    
}
