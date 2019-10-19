import {BaseEntity,Column,Entity,Index,JoinColumn,JoinTable,ManyToMany,ManyToOne,OneToMany,OneToOne,PrimaryColumn,PrimaryGeneratedColumn,RelationId} from "typeorm";
import {account} from "./account";


@Entity("workspace" ,{schema:"app_public" } )
export class workspace {

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
        

   
    @ManyToMany(()=>account, (account: account)=>account.workspaces)
    accounts:account[];
    
}
