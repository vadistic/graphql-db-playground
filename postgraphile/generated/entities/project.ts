import {BaseEntity,Column,Entity,Index,JoinColumn,JoinTable,ManyToMany,ManyToOne,OneToMany,OneToOne,PrimaryColumn,PrimaryGeneratedColumn,RelationId} from "typeorm";
import {client} from "./client";
import {time_entry} from "./time_entry";
import {account} from "./account";


@Entity("project" ,{schema:"app_public" } )
@Index("project_client_id_fkey",["client",])
export class project {

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
        nullable:false,
        name:"name"
        })
    name:string;
        

    @Column("text",{ 
        nullable:true,
        name:"description"
        })
    description:string | null;
        

   
    @ManyToOne(()=>client, (client: client)=>client.projects,{ onDelete: 'SET NULL', })
    @JoinColumn({ name:'client_id'})
    client:client | null;


   
    @OneToMany(()=>time_entry, (time_entry: time_entry)=>time_entry.project,{ onDelete: 'SET NULL' , })
    timeEntrys:time_entry[];
    

   
    @ManyToMany(()=>account, (account: account)=>account.projects)
    accounts:account[];
    
}
