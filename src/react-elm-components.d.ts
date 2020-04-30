declare class react_elm_components {
    constructor(props: any, context: any, updater: any);

    context: any;

    props: any;

    state: any;

    refs: any;

    componentDidMount(): void;

    componentWillUnmount(): void;

    initialize(node: any): void;

    render(): any;

    setState(): any;

    forceUpdate(): any;

    shouldComponentUpdate(prevProps: any): any;

}

export = react_elm_components;
