<script lang="ts">
    import Button from '$lib/components/ui/button/button.svelte';
    import RowCentered from '$lib/RowCentered.svelte';
    import BottleImage from '$lib/assets/Wine Bottle.png'
    import ColCentered from '$lib/ColCentered.svelte';
</script>

<div class="sm: flex flex-col h-screen justify-center items-center md:flex flex-col h-screen justify-center items-center lg:flex lg:flex-row h-screen justify-center items-center ">
    
    <div class="flex flex-col items-center mb-10 md:mb-0 lg:mb-0">
        <Button class="text-3xl sm:text-4xl md:text-5xl lg:text-5xl text-slate-400 mb-4 md:mb-10 lg:mb-20 p-10 " variant="link" href="/register">
            Regisztrálj egy üveget
        </Button>
        <Button class="text-3xl sm:text-4xl md:text-5xl lg:text-5xl text-slate-400 mb-4 md:mb-10 lg:mb-20 p-10" variant="link" href="/transfer">
            Ruházd át tulajdonjogod
        </Button>
    </div>

    <div class="sm: hidden md:hidden lg:block h-full ">
        <img class="h-full max-h-lg max-w-lg w-full object-cover" src={BottleImage} alt="Wine Bottle" />
    </div>

    <div class="flex flex-col items-center">
        <Button class="text-3xl sm:text-4xl md:text-5xl lg:text-6xl text-slate-400 mb-4 md:mb-10 lg:mb-20 p-10" variant="link" href="/check">
            Ellenőrizz egy üveget
        </Button>
        <Button class="text-3xl sm:text-4xl md:text-5xl lg:text-6xl text-slate-400 mb-4 md:mb-10 lg:mb-20 p-10" variant="link" href="/update">
            Frissíts egy üveget
        </Button>
    </div>
</div>