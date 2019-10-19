import {BaseEntity,Column,Entity,Index,JoinColumn,JoinTable,ManyToMany,ManyToOne,OneToMany,OneToOne,PrimaryColumn,PrimaryGeneratedColumn,RelationId} from "typeorm";
import {project} from "./project";
import {time_entry} from "./time_entry";


@Entity("client" ,{schema:"app_public" } )
export class client {

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
        

   
    @OneToMany(()=>project, (project: project)=>project.client,{ onDelete: 'SET NULL' , })
    projects:project[];
    

   
    @OneToMany(()=>time_entry, (time_entry: time_entry)=>time_entry.client,{ onDelete: 'SET NULL' , })
    timeEntrys:time_entry[];
    
}
