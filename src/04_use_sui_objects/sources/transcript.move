module use_sui_objects::transcript {
    use sui::object::{Self, UID, ID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use sui::event;

    struct WrapperTranscript has key, store {
        id: UID,
        history: u8,
        math: u8,
        literature: u8,
    }

    struct Folder has key {
        id: UID,
        transcript: WrapperTranscript,
        intended_address: address,
    }

    struct TeacherCap has key {
        id: UID,
    }

    struct TranscriptRequestEvent has copy, drop {
        wrapper_id: ID,
        requester: address,
        intended_address: address,
    }

    fun init(ctx: &mut TxContext) {
        let cap = TeacherCap {
            id: object::new(ctx),
        };
        transfer::transfer(cap, tx_context::sender(ctx));
    }

    public fun view_score(obj: &WrapperTranscript): u8 {
        obj.literature
    }

    public entry fun update_score(obj: &mut WrapperTranscript, score: u8) {
        obj.literature = score
    }

    public entry fun delete_transcript(obj: WrapperTranscript) {
        let WrapperTranscript { id, history: _, math: _, literature: _ } = obj;
        object::delete(id);
    }

    public entry fun create_wrappable_transcript(_: &TeacherCap, history: u8, math: u8, literature: u8, ctx: &mut TxContext) {
        let obj = WrapperTranscript {
            id: object::new(ctx),
            history: history,
            math: math,
            literature: literature,
        };
        event::emit(TranscriptRequestEvent {
            wrapper_id: object::uid_to_inner(&folder.id),
            requester: tx_context::sender(ctx),
            intended_address,
        });
        transfer::transfer(obj, tx_context::sender(ctx));
    }

    public entry fun pack_transcript(transcript: WrapperTranscript, intended_address: address, ctx: &mut TxContext) {
        let folder = Folder {
            id: object::new(ctx),
            transcript: transcript,
            intended_address: intended_address,
        };
        transfer::transfer(folder, intended_address);
    }

    public entry fun unpack_wrapped_transcript(folder: Folder, ctx: &mut TxContext) {
        assert!(folder.intended_address == tx_context::sender(ctx), 0);

        let Folder {
            id,
            transcript,
            intended_address: _,
        } = folder;
        transfer::transfer(transcript, tx_context::sender(ctx));
        object::delete(id);
    }

    public entry fun add_additional_teacher(_: &TeacherCap, new_teacher_address: address, ctx: &mut TxContext){
        transfer::transfer(
            TeacherCap {
                id: object::new(ctx)
            },
        new_teacher_address
        )
    }
}
